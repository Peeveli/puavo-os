# PuavoMenu main

from time import clock

from os import unlink, environ
from os.path import join as path_join, isfile as is_file

import socket               # for the IPC socket
import traceback

import gi
gi.require_version('Gtk', '3.0')        # explicitly require Gtk3, not Gtk2
from gi.repository import Gtk
from gi.repository import Gdk
from gi.repository import Pango
from gi.repository import GLib

import logger
from constants import *
from iconcache import ICONS48
from buttons import ProgramButton, MenuButton
from utils import localize
from utils_gui import load_image_at_size, create_separator, \
                      create_desktop_link, create_panel_link
from loader import load_menu_data
from conditionals import evaluate_file
import faves
from sidebar import Sidebar
from strings import STRINGS
from settings import SETTINGS


class PuavoMenu(Gtk.Window):

    def error_message(self, message, secondary_message=None):
        """Show a modal error message box."""

        dialog = Gtk.MessageDialog(parent=self,
                                   flags=Gtk.DialogFlags.MODAL,
                                   type=Gtk.MessageType.ERROR,
                                   buttons=Gtk.ButtonsType.OK,
                                   message_format=message)

        if secondary_message:
            dialog.format_secondary_markup(secondary_message)

        self.disable_out_of_focus_hide()
        dialog.run()
        dialog.hide()
        self.enable_out_of_focus_hide()


    def __init__(self):

        """This is where the magic happens."""

        start_time = clock()

        super().__init__()

        # Ensure the window is not visible until it's ready
        self.set_visible(False)

        self.set_type_hint(Gtk.WindowType.TOPLEVEL)

        # ----------------------------------------------------------------------
        # Set up a domain socket for show/hide messages from the panel
        # button shell extension. This is done early, because if it
        # fails, we simply exit. We can't do *anything* without it.
        # (The only other choice would be to always display the menu,
        # never allowing the user to hide it because without the socket
        # it cannot be reopened.)

        try:
            # Clean leftovers
            unlink(SETTINGS.socket)
        except OSError:
            pass

        try:
            self.__socket = socket.socket(socket.AF_UNIX, socket.SOCK_DGRAM)
            self.__socket.bind(SETTINGS.socket)
        except Exception as e:
            # Oh dear...
            import syslog

            logger.error('Unable to create a domain socket for IPC!')
            logger.error('Reason: {0}'.format(e))
            logger.error('Socket name: "{0}"'.format(SETTINGS.socket))
            logger.error('This is a fatal error, stopping here.')

            syslog.syslog(syslog.LOG_CRIT,
                          'PuavoMenu IPC socket "{0}" creation failed: {1}'.
                          format(SETTINGS.socket, e))

            syslog.syslog(syslog.LOG_CRIT,
                          'PuavoMenu stops here. Contact Opinsys support.')

            exit(1)

        # Start listening the socket. Use glib's watch functions, then
        # we don't need to use threads (which work too, but are harder
        # to clean up and we'll run into problems with multihtreaded
        # xlib programs).

        # https://developer.gnome.org/pygobject/stable/glib-functions.html#
        #   function-glib--io-add-watch
        GLib.io_add_watch(self.__socket,
                          GLib.IO_IN,
                          self.__socket_watcher)

        # ----------------------------------------------------------------------

        # Exit stuff. By default the program cannot be exited normally.
        self.__exit_permitted = False
        self.connect('delete-event', self.__try_exit)

        # Conditional data
        self.__conditions = {}

        # The actual menu data. Can be empty...
        self.__programs = {}
        self.__menus = {}
        self.__categories = {}
        self.__category_index = []
        self.__current_category = -1

        # The current menu, if any
        self.__current_menu = None

        # The current menu/program buttons in the current
        # category and menu, if any
        self.__buttons = []

        # Background image for top-level menus
        try:
            image_name = 'folder_dark.png' if SETTINGS.dark_theme else 'folder.png'

            self.__menu_background = \
                load_image_at_size(SETTINGS.res_dir + image_name, 150, 110)
        except Exception as e:
            logger.error('Can\'t load the menu background image: {0}'.
                         format(e))
            self.__menu_background = None

        # ----------------------------------------------------------------------
        # Create the window elements

        # Set window style
        if SETTINGS.dev_mode:
            # makes developing slightly easier
            self.set_skip_taskbar_hint(False)
            self.set_skip_pager_hint(False)
            self.set_deletable(True)
            self.__exit_permitted = True
        else:
            self.set_skip_taskbar_hint(True)
            self.set_skip_pager_hint(True)
            self.set_deletable(False)       # no close button

        self.set_decorated(False)
        self.set_resizable(False)
        self.set_title('PuavoMenuUniqueName')
        self.set_size_request(WINDOW_WIDTH, WINDOW_HEIGHT)
        self.set_position(Gtk.WindowPosition.CENTER)

        # Top-level container for all widgets. This is needed, because
        # a window can contain only one child widget and we can have
        # dozens of them. Every widget has a fixed position and size,
        # because the menu isn't user-resizable.
        self.__main_container = Gtk.Fixed()
        self.__main_container.set_size_request(WINDOW_WIDTH,
                                               WINDOW_HEIGHT)

        if SETTINGS.dev_mode:
            # The devtools menu
            self.__devtools = Gtk.Button()
            self.__devtools.set_label('Development tools')
            self.__devtools.connect('clicked', self.__devtools_menu)
            self.__devtools.show()
            self.__main_container.put(
                self.__devtools,
                PROGRAMS_LEFT + PROGRAMS_WIDTH - SEARCH_WIDTH - MAIN_PADDING,
                MAIN_PADDING + SEARCH_HEIGHT + 5)

        # ----------------------------------------------------------------------
        # Menus/programs list

        # TODO: Gtk.Notebook isn't the best choice for this

        # Category tabs
        self.__category_buttons = Gtk.Notebook()
        self.__category_buttons.set_size_request(CATEGORIES_WIDTH, -1)
        self.__category_buttons.set_current_page(self.__current_category)
        self.__category_buttons.connect('switch-page',
                                        self.__clicked_category)
        self.__main_container.put(self.__category_buttons,
                                  PROGRAMS_LEFT, MAIN_PADDING)

        # The back button
        self.__back_button = Gtk.Button()
        self.__back_button.set_label('<<')
        self.__back_button.connect('clicked',
                                   self.__clicked_back_button)
        self.__back_button.set_size_request(BACK_BUTTON_WIDTH, -1)
        self.__main_container.put(self.__back_button,
                                  BACK_BUTTON_X,
                                  BACK_BUTTON_Y)

        # The search box

        # filter unwanted characters from queries
        self.__translation_table = \
            dict.fromkeys(map(ord, "*^?{[]}/\\_+=\"\'#%&()'`@$<>|~"),
                          None)

        self.__search = Gtk.SearchEntry()
        self.__search.set_size_request(SEARCH_WIDTH, SEARCH_HEIGHT)
        self.__search.set_max_length(10)     # if you need more than this,
                                             # it probably doesn't exist
        self.__search_changed_signal = \
            self.__search.connect('changed', self.__do_search)
        self.__search_keypress_signal = \
            self.__search.connect('key-press-event', self.__search_keypress)
        self.__search.set_placeholder_text(
            localize(STRINGS['search_placeholder'], SETTINGS.language))
        self.__main_container.put(
            self.__search,
            PROGRAMS_LEFT + PROGRAMS_WIDTH - SEARCH_WIDTH - MAIN_PADDING,
            MAIN_PADDING)

        # Menu label and description
        self.__menu_title = Gtk.Label()
        self.__menu_title.set_size_request(PROGRAMS_WIDTH, -1)
        self.__menu_title.set_ellipsize(Pango.EllipsizeMode.END)
        self.__menu_title.set_justify(Gtk.Justification.CENTER)
        self.__menu_title.set_alignment(0.0, 0.0)
        self.__menu_title.set_use_markup(True)
        self.__main_container.put(
            self.__menu_title,
            BACK_BUTTON_X + BACK_BUTTON_WIDTH +  MAIN_PADDING,
            BACK_BUTTON_Y + 3)

        # The main programs list
        self.__programs_container = Gtk.ScrolledWindow()
        self.__programs_container.set_size_request(PROGRAMS_WIDTH,
                                                   PROGRAMS_HEIGHT)
        self.__programs_container.set_policy(Gtk.PolicyType.NEVER,
                                             Gtk.PolicyType.AUTOMATIC)
        self.__programs_container.set_shadow_type(Gtk.ShadowType.NONE)
        self.__programs_icons = Gtk.Fixed()
        self.__programs_container.add_with_viewport(self.__programs_icons)
        self.__main_container.put(self.__programs_container,
                                  PROGRAMS_LEFT, PROGRAMS_TOP)

        # Placeholder for empty categories, menus and search results
        self.__empty = Gtk.Label()
        self.__empty.set_size_request(PROGRAMS_WIDTH, PROGRAMS_HEIGHT)
        self.__empty.set_use_markup(True)
        self.__empty.set_justify(Gtk.Justification.CENTER)
        self.__empty.set_alignment(0.5, 0.5)
        self.__main_container.put(self.__empty,
                                  PROGRAMS_LEFT, PROGRAMS_TOP)

        # Faves list
        self.__faves_sep = Gtk.Separator(orientation=
                                         Gtk.Orientation.HORIZONTAL)
        self.__faves_sep.set_size_request(PROGRAMS_WIDTH, 1)
        self.__main_container.put(self.__faves_sep,
                                  PROGRAMS_LEFT,
                                  PROGRAMS_TOP + PROGRAMS_HEIGHT + MAIN_PADDING)

        self.__faves = faves.FavesList(self)
        self.__faves.set_size_request(PROGRAMS_WIDTH,
                                      PROGRAM_BUTTON_HEIGHT + 2)
        self.__main_container.put(self.__faves,
                                  PROGRAMS_LEFT, FAVES_TOP)

        # ----------------------------------------------------------------------
        # The sidebar: the user avatar, buttons, host infos

        create_separator(container=self.__main_container,
                         x=SIDEBAR_LEFT - MAIN_PADDING,
                         y=MAIN_PADDING,
                         w=1,
                         h=WINDOW_HEIGHT - (MAIN_PADDING * 2),
                         orientation=Gtk.Orientation.VERTICAL)

        self.__sidebar = Sidebar(self)

        self.__main_container.put(self.__sidebar.container,
                                  SIDEBAR_LEFT,
                                  SIDEBAR_TOP)

        # ----------------------------------------------------------------------
        # Setup GTK signal handlers

        # Listen for Esc keypresses for manually hiding the window
        self.__main_keypress_signal = \
            self.connect('key-press-event', self.__check_for_esc)

        self.__focus_signal = None

        if not SETTINGS.autohide:
            # Keep the window on top of everything and show it
            self.set_visible(True)
            self.set_keep_above(True)
        else:
            # In auto-hide mode, hide the window when it loses focus
            self.enable_out_of_focus_hide()

        self.connect('focus-in-event', self.__main_got_focus)
        self.__search.connect('focus-in-event', self.__search_in)
        self.__search.connect('focus-out-event', self.__search_out)

        # ----------------------------------------------------------------------
        # UI done

        self.add(self.__main_container)
        self.__main_container.show()

        # DO NOT CALL self.show_all() HERE, the window has hidden elements
        # that are shown/hidden on demand. And we don't even have any
        # menu data yet to show.

        end_time = clock()
        logger.print_time('Window init time', start_time, end_time)

        # Finally, load the menu data and show the UI
        self.__load_data()


    # --------------------------------------------------------------------------
    # Menus and programs list handling


    # Replaces the existing menu and program buttons (if any) with new
    # buttons. The new button list can be empty.
    def __fill_programs_list(self, new_buttons, show=False):
        if show:
            self.__programs_icons.hide()

        # Clear the old buttons first
        for b in self.__buttons:
            b.destroy()

        self.__buttons = []

        xp = 0
        yp = 0

        # Insert the new icons and arrange them into rows
        for n, b in enumerate(new_buttons):
            self.__programs_icons.put(b, xp, yp)
            self.__buttons.append(b)

            xp += PROGRAM_BUTTON_WIDTH

            if (n + 1) % PROGRAMS_PER_ROW == 0:
                xp = 0
                yp += PROGRAM_BUTTON_HEIGHT

        self.__programs_icons.show_all()

        if show:
            self.__programs_icons.show()


    # (Re-)Creates the current category or menu view
    def __create_current_menu(self):
        new_buttons = []

        self.__empty.hide()

        if self.__current_menu is None:
            # Top-level category view
            if len(self.__category_index) > 0 and \
                    self.__current_category < len(self.__category_index):
                cat = self.__categories[self.__category_index[
                    self.__current_category]]

                # Menus first...
                for m in cat.menus:
                    mb = MenuButton(self, m.title, m.icon, m.description,
                                    m, self.__menu_background)
                    mb.connect('clicked', self.__clicked_menu_button)
                    new_buttons.append(mb)

                # ...then programs
                for p in cat.programs:
                    pb = ProgramButton(self, p.title, p.icon,
                                       p.description, p)
                    pb.connect('clicked', self.clicked_program_button)
                    new_buttons.append(pb)

            # Special situations
            if len(self.__category_index) == 0:
                self.__show_empty_message(STRINGS['menu_no_data_at_all'])
            elif len(new_buttons) == 0:
                self.__show_empty_message(STRINGS['menu_empty_category'])

        else:
            # Submenu view, have only programs
            for p in self.__current_menu.programs:
                pb = ProgramButton(self, p.title, p.icon, p.description, p)
                pb.connect('clicked', self.clicked_program_button)
                new_buttons.append(pb)

            # Special situations
            if len(self.__current_menu.programs) == 0:
                self.__show_empty_message(STRINGS['menu_empty_menu'])

        self.__fill_programs_list(new_buttons, True)


    # Changes the menu title and description, and shows or hides
    # the whole thing if necessary
    def __update_menu_title(self):
        if self.__current_menu is None:
            # top-level
            self.__menu_title.hide()
            return

        # TODO: "big" and "small" are not good sizes, we need to be explicit
        if self.__current_menu.description is None:
            self.__menu_title.set_markup('<big>{0}</big>'.
                                         format(self.__current_menu.title))
        else:
            self.__menu_title.set_markup('<big>{0}</big>  <small>{1}</small>'.
                                         format(self.__current_menu.title,
                                                self.__current_menu.description))

        self.__menu_title.show()


    # --------------------------------------------------------------------------
    # Searching


    # Returns the current search term, filtered and cleaned
    def __get_search_text(self):
        return self.__search.get_text().strip().translate(self.__translation_table)


    def __hide_search_results(self):
        self.__empty.hide()
        self.__create_current_menu()


    # Searches the programs list using a string, then replaces the menu list
    # with results
    def __do_search(self, edit):
        key = self.__get_search_text()

        if len(key) == 0:
            # reset
            self.__hide_search_results()
            return

        import re

        matches = []

        for name in self.__programs:
            p = self.__programs[name]

            if re.search(key, p.title, re.IGNORECASE):
                matches.append(p)
                continue

            # check the .desktop file name
            if p.original_desktop_file:
                if re.search(key,
                             p.original_desktop_file.replace('.desktop', ''),
                             re.IGNORECASE):
                    matches.append(p)
                    continue

            # keyword search must be done last, otherwise a program
            # can appear multiple times in the search results
            for k in p.keywords:
                if re.search(key, k, re.IGNORECASE):
                    matches.append(p)
                    break

        matches = sorted(matches, key=lambda p: p.title)

        if len(matches) > 0:
            self.__empty.hide()
        else:
            self.__show_empty_message(STRINGS['search_no_results'])

        # create new buttons for results
        new_buttons = []

        for m in matches:
            b = ProgramButton(self, m.title, m.icon, m.description, m)
            b.connect('clicked', self.clicked_program_button)
            new_buttons.append(b)

        self.__fill_programs_list(new_buttons, True)


    # Ensures the search entry is empty
    def __clear_search_field(self):
        # Clear the search box without triggering another search
        self.__search.disconnect(self.__search_keypress_signal)
        self.__search.disconnect(self.__search_changed_signal)
        self.__search.set_text('')
        self.__search_keypress_signal = \
            self.__search.connect('key-press-event', self.__search_keypress)
        self.__search_changed_signal = \
            self.__search.connect('changed', self.__do_search)


    # Responds to Esc and Enter keypresses in the search field
    def __search_keypress(self, widget, key_event):
        if key_event.keyval == Gdk.KEY_Escape:
            if len(self.__get_search_text()):
                # Cancel an ongoing search
                self.__clear_search_field()
                self.__hide_search_results()
            else:
                # The search field is empty, hide the window (we have
                # another Esc handler elsewhere that's used when the
                # search box has no focus)
                logger.debug('Search field is empty and Esc pressed, '
                             'hiding the window')
                self.autohide()
        elif key_event.keyval == Gdk.KEY_Return:
            if len(self.__get_search_text()) and (len(self.__buttons) == 1):
                # There's only one search match and the user pressed
                # Enter, so launch it!
                self.clicked_program_button(self.__buttons[0])
                self.__clear_search_field()
                self.__hide_search_results()

        return False


    # --------------------------------------------------------------------------
    # Menu/category navigation


    # Change the category
    def __clicked_category(self, widget, frame, num):
        self.__clear_search_field()
        self.__back_button.hide()
        self.__current_category = num
        self.__current_menu = None
        self.__create_current_menu()
        self.__update_menu_title()


    # Go back to top level
    def __clicked_back_button(self, e):
        self.__clear_search_field()
        self.__back_button.hide()
        self.__current_menu = None
        self.__create_current_menu()
        self.__update_menu_title()


    # Enter a menu
    def __clicked_menu_button(self, e):
        self.__clear_search_field()
        self.__back_button.show()
        self.__current_menu = e.data
        self.__create_current_menu()
        self.__update_menu_title()


    # Shows an "empty" message in the main programs list. Used when a
    # menu/category is empty, or there are no search results.
    def __show_empty_message(self, msg):
        if isinstance(msg, dict):
            msg = localize(msg, SETTINGS.language)

        self.__empty.set_markup(
            '<span color="#888" size="large"><i>{0}</i></span>'.
            format(msg))
        self.__empty.show()


    # --------------------------------------------------------------------------
    # Button click handlers


    # Called directly from ProgramButton
    def add_program_to_desktop(self, p):
        """Creates a desktop shortcut to a program."""

        if not SETTINGS.desktop_dir:
            return

        # Create the link file
        # TODO: use the *original* .desktop file if it exists
        name = path_join(SETTINGS.desktop_dir, '{0}.desktop'.format(p.title))

        logger.info('Adding program "{0}" to the desktop, output="{1}"'.
                    format(p.title, name))

        try:
            create_desktop_link(name, p)
        except Exception as e:
            logger.error('Desktop link creation failed')
            logger.error(e)

            self.error_message(
                localize(STRINGS['desktop_link_failed'], SETTINGS.language),
                str(e))


    # Called directly from ProgramButton
    def add_program_to_panel(self, p):
        logger.info('Adding program "{0}" (id="{1}") to the bottom panel'.
                    format(p.title, p.name))

        try:
            create_panel_link(p)
        except Exception as e:
            logger.error('Panel icon creation failed')
            logger.error(e)

            self.error_message(
                localize(STRINGS['panel_link_failed'], SETTINGS.language),
                str(e))


    # Called directly from ProgramButton
    def remove_program_from_faves(self, p):
        print('Removing program "{0}" from the faves'.format(p.title))
        p.uses = 0
        self.__faves.update(self.__programs)


    # Resets the menu back to the default view
    def __reset_menu(self):
        self.__current_category = 0
        self.__category_buttons.set_current_page(0)
        self.__current_menu = None
        self.__clear_search_field()
        self.__back_button.hide()
        self.__create_current_menu()
        self.__update_menu_title()


    # Launch a program. This is a public method, it is called from other
    # files (buttons and faves) to launch programs.
    def clicked_program_button(self, button):
        p = button.data
        p.uses += 1
        self.__faves.update(self.__programs)

        print('Clicked program button "{0}", usage counter is {1}'.
              format(p.title, p.uses))

        if p.command is None:
            logger.error('No command defined for program "{0}"'.
                         format(p.title))
            return

        # Try to launch the program
        try:
            import subprocess

            if p.type in (PROGRAM_TYPE_DESKTOP, PROGRAM_TYPE_CUSTOM):
                # TODO: do we really need to open a shell for this?
                cmd = ['sh', '-c', p.command, '&']
            elif p.type == PROGRAM_TYPE_WEB:
                # Opens in the default browser
                cmd = ['xdg-open', p.command]
            else:
                raise RuntimeError('Unknown program type {0}'.
                                   format(p.type))

            logger.info('Executing "{0}"'.format(cmd))

            subprocess.Popen(cmd,
                             stdout=subprocess.PIPE,
                             stderr=subprocess.PIPE)

            # Of course, we never check the return value here, so we
            # don't know if the command actually worked...

            self.autohide()

            if SETTINGS.reset_view_after_start:
                # Go back to the default view
                self.__clear_search_field()
                self.__hide_search_results()
                self.__reset_menu()

        except Exception as e:
            logger.error('Could not launch program "{0}": {1}'.
                         format(p.command, str(e)))
            self.error_message(localize(STRINGS['program_launching_failed'],
                               SETTINGS.language),
                               str(e))
            return False


    # --------------------------------------------------------------------------
    # Window visibility management


    # Hides the window if Esc is pressed when the keyboard focus
    # is not in the search box (the search box has its own Esc
    # handler).
    def __check_for_esc(self, widget, key_event):
        if key_event.keyval != Gdk.KEY_Escape:
            return

        if SETTINGS.dev_mode:
            logger.debug('Ignoring Esc in development mode')
        else:
            logger.debug('Esc pressed, hiding the window')
            self.set_keep_above(False)
            self.set_visible(False)


    # Removes the out-of-focus autohiding. You need to call this before
    # displaying popup menus, because they trigger out-of-focus signals!
    # This method can be called as-is, but it is also used as a GTK signal
    # handler callback; the signal handler likes to give all sorts of
    # useless (to us) arguments to the function, so they're collected
    # and ignored.
    def disable_out_of_focus_hide(self, *unused):
        if not SETTINGS.autohide:
            return

        if self.__focus_signal:
            logger.debug('Out-of-focus signal handler deactivated')
            self.disconnect(self.__focus_signal)
            self.__focus_signal = None


    # (Re)enables window out-of-focus autohiding. You need to call this
    # after a popup menu has been closed.
    def enable_out_of_focus_hide(self, *unused):
        if not SETTINGS.autohide:
            return

        if not self.__focus_signal:
            logger.debug('Out-of-focus signal handler activated')
            self.__focus_signal = \
                self.connect('focus-out-event', self.__main_lost_focus)


    def __main_got_focus(self, *unused):
        pass


    def __main_lost_focus(self, *unused):
        self.autohide()


    def __search_in(self, *unused):
        pass


    def __search_out(self, *unused):
        self.__search.grab_focus()


    # If autohiding is enabled, hides the window when it loses focus. Public method, called
    # from other files.
    def autohide(self, *unused):
        if SETTINGS.autohide:
            logger.debug('Autohiding the window')
            self.set_keep_above(False)
            self.set_visible(False)


    # Quits the program, if permitted. The signal handlers always call
    # this with "force=True" because they HAVE to kill the program.
    def go_away(self, force=False):
        if force or self.__exit_permitted:
            logger.info('Shutdown initiated')
            self.set_keep_above(False)
            self.set_visible(False)
            Gtk.main_quit()
        else:
            logger.info('Exit not permitted')
            return True


    # TODO: put this in a lambda
    def __try_exit(self, menu, event):
        return self.go_away()


    # Extracts X/Y coordinates from a list
    def __parse_position(self, args):
        if len(args) == 0:
            return None

        try:
            if args[0] == 'center':
                # Center the menu at the mouse cursor
                from Xlib import display

                data = display.Display().screen().root.query_pointer()._data

                return (
                    int(data['root_x']) - int(WINDOW_WIDTH / 2),
                    int(data['root_y']) - int(WINDOW_HEIGHT / 2)
                )
            elif args[0] == 'corner':
                # Position the lower left corner at the specified
                # coordinates
                # TODO: use window gravity for this?
                return (int(args[1]), int(args[2]) - WINDOW_HEIGHT)
        except:
            pass

        return None


    # Responds to commands sent through the control socket
    def __socket_watcher(self, source, condition, *args):
        try:
            data, _ = self.__socket.recvfrom(1024)
            data = (data or b'').decode('utf-8').strip().split(' ')

            if len(data) == 0:
                logger.debug('Received an empty command through the socket?')
                return True

            cmd = data[0]
            data = data[1:]

            logger.debug('Socket command: "{0}"'.format(cmd))
            logger.debug('Socket arguments: "{0}"'.format(data))

            if cmd == 'hide':
                # Hide the window

                if SETTINGS.reset_view_after_start:
                    # Go back to the default view
                    self.__clear_search_field()
                    self.__hide_search_results()
                    self.__reset_menu()

                if self.is_visible():
                    logger.debug('Hiding the window')
                    self.__search.grab_focus()
                    self.set_keep_above(False)
                    self.set_visible(False)
                else:
                    logger.debug('Already hidden')
            elif cmd == 'show':
                # Show the window

                if SETTINGS.reset_view_after_start:
                    # Go back to the default view
                    self.__clear_search_field()
                    self.__hide_search_results()
                    self.__reset_menu()

                if self.is_visible():
                    logger.debug('Already visible')
                else:
                    coords = self.__parse_position(data)

                    if coords:
                        logger.debug(coords)
                        self.move(coords[0], coords[1])

                    self.set_keep_above(True)
                    self.set_visible(True)
                    self.present()

                    self.__search.grab_focus()
                    self.activate_focus()
            elif cmd == 'toggle':
                # Toggle the window visibility

                if SETTINGS.reset_view_after_start:
                    # Go back to the default view
                    self.__clear_search_field()
                    self.__hide_search_results()
                    self.__reset_menu()

                if self.is_visible():
                    logger.debug('Toggling window visibility (hide)')
                    self.__search.grab_focus()
                    self.set_keep_above(False)
                    self.set_visible(False)
                else:
                    logger.debug('Toggling window visibility (show)')
                    coords = self.__parse_position(data)

                    if coords:
                        logger.debug(coords)
                        self.move(coords[0], coords[1])

                    self.set_keep_above(True)
                    self.set_visible(True)
                    self.present()

                    self.__search.grab_focus()
                    self.activate_focus()
            else:
                logger.debug('Unknown command "{0}" received, args={1}'.
                             format(cmd, data))
        except Exception as e:
            logger.error('Socket command processing failed!')
            logger.error(e)

        # False will remove the handler, that's not what we want
        return True


    # --------------------------------------------------------------------------
    # Menu data loading and handling


    def __unload_data(self):
        """Completely removes all menu data. Hides everything programs-
        related from the UI."""

        self.__category_buttons.hide()

        num_pages = self.__category_buttons.get_n_pages()

        for i in range(0, num_pages):
            self.__category_buttons.remove_page(-1)

        self.__clear_search_field()
        self.__back_button.hide()
        self.__search.hide()

        self.__empty.hide()

        self.__menu_title.hide()
        self.__programs_icons.hide()
        self.__programs_container.hide()

        self.__faves_sep.hide()
        self.__faves.clear()
        self.__faves.hide()

        for b in self.__buttons:
            b.destroy()

        self.__buttons = []

        # Actually remove the menu data
        self.__conditions = {}
        self.__programs = {}
        self.__menus = {}
        self.__categories = {}
        self.__category_index = []
        self.__current_category = -1
        self.__current_menu = None

        if ICONS48.stats()['num_icons'] != 0:
            # Purge existing icons
            ICONS48.clear()


    def __load_data(self):
        """Loads menu data and sets up the UI. Returns false if
        something fails."""

        # Don't mess up error and warning counts
        logger.reset_counters()

        # Files/strings to be loaded
        sources = [
            ['f', 'menudata.yaml'],
            #['s', koodi],
        ]

        # Paths for .desktop files
        desktop_dirs = [
            '/usr/share/applications',
            '/usr/share/applications/kde4',
            '/usr/local/share/applications',
        ]

        # Where to search for icons
        icon_dirs = [
            '/usr/share/icons/hicolor/48x48/apps',
            '/usr/share/icons/hicolor/64x64/apps',
            '/usr/share/icons/hicolor/128x128/apps',
            '/usr/share/icons/Neu/128x128/categories',
            '/usr/share/icons/hicolor/scalable/apps',
            '/usr/share/icons/hicolor/scalable',
            '/usr/share/icons/Faenza/categories/64',
            '/usr/share/icons/Faenza/apps/48',
            '/usr/share/icons/Faenza/apps/96',
            '/usr/share/app-install/icons',
            '/usr/share/pixmaps',
            '/usr/share/icons/hicolor/32x32/apps',
        ]

        conditional_files = [
            'conditions.yaml'
        ]

        for s in sources:
            if s[0] == 'f':
                s[1] = SETTINGS.menu_dir + s[1]

        start_time = clock()

        # Load and evaluate conditionals
        self.__conditions = {}

        for c in conditional_files:
            r = evaluate_file(SETTINGS.menu_dir + c)
            self.__conditions.update(r)

        conditional_time = clock()

        logger.print_time('Conditional evaluation time',
                          start_time, conditional_time)

        programs = {}
        menus = {}
        categories = {}
        category_index = []

        id_to_path_mapping = {}

        # Load everything
        try:
            programs, menus, categories, category_index = \
                load_menu_data(sources,
                               desktop_dirs,
                               SETTINGS.language,
                               self.__conditions)
        except Exception as e:
            logger.error('Could not load menu data!')
            logger.traceback(traceback.format_exc())
            return False

        if not programs:
            return False

        parsing_time = clock()

        # Locate and load icon files
        logger.info('Loading icons...')
        num_missing_icons = 0

        for name in programs:
            p = programs[name]

            if not p.used:
                continue

            if p.icon is None:
                # This should not happen, ever
                logger.error('The impossible happened: program "{0}" '
                             'has no icon at all!'.format(name))
                num_missing_icons += 1
                continue

            if name in id_to_path_mapping:
                p.icon_is_path = True
                p.icon = id_to_path_mapping[name]

            if p.icon_is_path:
                # Just use it
                if is_file(p.icon):
                    icon = ICONS48.load_icon(p.icon)

                    if icon.usable:
                        p.icon = icon
                        continue

                # Okay, the icon was specified, but it could not be loaded.
                # Try automatic loading.
                p.icon_is_path = False

            # Locate the icon specified in the .desktop file
            icon_path = None

            for s in icon_dirs:
                # Try the name as-is first
                path = path_join(s, p.icon)

                if is_file(path):
                    icon_path = path
                    break

                if not icon_path:
                    # Then try the different extensions
                    for e in ICON_EXTENSIONS:
                        path = path_join(s, p.icon + e)

                        if is_file(path):
                            icon_path = path
                            break

                if icon_path:
                    break

            # Nothing found
            if not icon_path:
                logger.error('Icon "{0}" for program "{1}" not found in '
                             'icon load paths'.format(p.icon, name))
                p.icon = None
                num_missing_icons += 1
                continue

            p.icon = ICONS48.load_icon(path)

            if not p.icon.usable:
                logger.warn('Found an icon "{0}" for program "{1}", but '
                            'it could not be loaded'.
                            format(path, name))
                num_missing_icons += 1
            else:
                id_to_path_mapping[name] = path

        for name in menus:
            m = menus[name]

            if m.icon is None:
                logger.warn('Menu "{0}" has no icon defined'.format(name))
                num_missing_icons += 1
                continue

            if not is_file(m.icon):
                logger.error('Icon "{0}" for menu "{1}" does not exist'.
                             format(m.icon, name))
                m.icon = None
                num_missing_icons += 1
                continue

            m.icon = ICONS48.load_icon(m.icon)

            if not m.icon.usable:
                logger.warn('Found an icon "{0}" for menu "{1}", but '
                            'it could not be loaded'.
                            format(path, name))
                num_missing_icons += 1

        end_time = clock()

        if num_missing_icons == 0:
            logger.info('No missing icons')
        else:
            logger.info('Have {0} missing or unloadable icons'.
                        format(num_missing_icons))

        stats = ICONS48.stats()
        logger.info('Number of 48-pixel icons cached: {0}'.
                    format(stats['num_icons']))
        logger.info('Number of 48-pixel atlas surfaces: {0}'.
                    format(stats['num_atlases']))

        logger.print_time('Icon loading time', parsing_time, end_time)

        if logger.have_warnings():
            logger.info('{0} warning(s) generated'.
                        format(logger.num_warnings()))

        if logger.have_errors():
            logger.info('{0} error(s) generated'.
                        format(logger.num_errors()))

        logger.print_time('Total loading time', start_time, end_time)

        # Replace existing menu data, if any
        self.__programs = programs
        self.__menus = menus
        self.__categories = categories
        self.__category_index = category_index
        self.__current_category = 0

        # Prepare the user interface
        for c in self.__category_index:
            cat = self.__categories[c]

            frame = Gtk.Frame()
            label = Gtk.Label(cat.title)
            frame.show()
            label.show()
            self.__category_buttons.append_page(frame, label)

        if len(self.__category_index) > 0:
            self.__category_buttons.show()

        self.__create_current_menu()

        self.__clear_search_field()
        self.__back_button.hide()
        self.__empty.hide()
        self.__search.show()
        self.__menu_title.hide()

        self.__programs_container.show()

        faves.load_use_counts(self.__programs)
        self.__faves.update(self.__programs)
        self.__faves_sep.show()
        self.__faves.show()

        self.__search.show()
        self.__search.grab_focus()

        return True


    # --------------------------------------------------------------------------
    # Development helpers


    # The devtools menu and its commands
    def __devtools_menu(self, button):
        if not SETTINGS.dev_mode:
            return

        def remove(x):
            if self.__programs:
                logger.debug('=' * 20)
                logger.debug('Purging all loaded menu data!')
                logger.debug('=' * 20)
                self.__unload_data()

        def reload(x):
            # remember where we are
            prev_menu = self.__current_menu.name if self.__current_menu \
                else None
            prev_cat = self.__category_index[self.__current_category] \
                if self.__current_category != -1 else None

            # TODO: Don't clear current data if the reload fails
            logger.debug('=' * 20)
            logger.debug('Reloading all menu data!')
            logger.debug('=' * 20)

            if self.__programs:
                self.__unload_data()

            if not self.__load_data():
                self.error_message('Failed to load menu data',
                                   'See the console for more details')
            else:
                # try to restore the previous menu and category
                for n, c in enumerate(self.__category_index):
                    if c == prev_cat:
                        logger.debug('Restoring category "{0}" after reload'.
                                     format(prev_cat))
                        self.__current_category = n
                        self.__category_buttons.set_current_page(n)
                        break

                if prev_menu and prev_menu in self.__menus:
                    logger.debug('Restoring menu "{0}" after reload'.
                                 format(prev_menu))
                    self.__current_menu = self.__menus[prev_menu]
                    self.__create_current_menu()
                    self.__back_button.show()
                    self.__update_menu_title()

            logger.debug('Menu data reload complete')

        def toggle_autohide(x):
            SETTINGS.autohide = not SETTINGS.autohide

        def show_conditionals(x):
            s = ''

            for k, v in self.__conditions.items():
                if not v[0]:
                    # highlight indeterminate conditionals
                    s += '<span foreground="red">'

                s += '{0}: usable={1} value={2}'. \
                     format(k, str(v[0]), str(v[1]))

                if not v[0]:
                    s += '</span>'

                s += '\n'

            self.error_message('Conditionals', s)

        def permit_exit(x):
            self.__exit_permitted = not self.__exit_permitted
            logger.debug('Normal exiting ' +
                         ('ENABLED' if self.__exit_permitted else 'DISABLED'))

        def force_exit(x):
            logger.debug('Devmenu force exit initiated!')
            self.go_away(True)


        dev_menu = Gtk.Menu()

        reload_item = Gtk.MenuItem('(Re)load menu data')
        reload_item.connect('activate', reload)
        reload_item.show()
        dev_menu.append(reload_item)

        remove_item = Gtk.MenuItem('Unload all menu data')
        remove_item.connect('activate', remove)
        remove_item.show()
        dev_menu.append(remove_item)

        conditionals_item = Gtk.MenuItem('Show conditional values...')
        conditionals_item.connect('activate', show_conditionals)
        conditionals_item.show()
        dev_menu.append(conditionals_item)

        sep = Gtk.SeparatorMenuItem()
        sep.show()
        dev_menu.append(sep)

        autohide_item = Gtk.CheckMenuItem('Autohide window')
        autohide_item.set_active(SETTINGS.autohide)
        autohide_item.connect('activate', toggle_autohide)
        autohide_item.show()
        dev_menu.append(autohide_item)

        sep = Gtk.SeparatorMenuItem()
        sep.show()
        dev_menu.append(sep)

        permit_exit_item = Gtk.CheckMenuItem('Permit normal program exit')
        permit_exit_item.set_active(self.__exit_permitted)
        permit_exit_item.connect('activate', permit_exit)
        permit_exit_item.show()
        dev_menu.append(permit_exit_item)

        force_exit_item = Gtk.MenuItem('Force program exit')
        force_exit_item.connect('activate', force_exit)
        force_exit_item.show()
        dev_menu.append(force_exit_item)

        # Prevent autohide when the menu is open
        self.disable_out_of_focus_hide()
        dev_menu.connect('deactivate', self.enable_out_of_focus_hide)

        dev_menu.popup(
            parent_menu_shell=None,
            parent_menu_item=None,
            func=None,
            data=None,
            button=1,
            activate_time=0)


# ------------------------------------------------------------------------------


# Trap certain signals and exit the menu gracefully if they're caught
# Taken from https://stackoverflow.com/a/26457317 and then mutilated.
def setup_signal_handlers(menu):
    import signal

    def signal_action(signal):
        if signal in (signal.SIGHUP, signal.SIGINT, signal.SIGTERM):
            logger.info('Caught signal {0}, exiting gracefully...'.
                        format(signal))
            menu.go_away(True)


    def idle_handler(*args):
        GLib.idle_add(signal_action, priority=GLib.PRIORITY_HIGH)


    def handler(*args):
        signal_action(args[0])


    def install_glib_handler(sig):
        GLib.unix_signal_add(GLib.PRIORITY_HIGH, sig, handler, sig)


    SIGS = [getattr(signal, s, None) for s in 'SIGHUP SIGINT SIGTERM'.split()]

    for sig in filter(None, SIGS):
        signal.signal(sig, idle_handler)
        GLib.idle_add(install_glib_handler, sig,
                      priority=GLib.PRIORITY_HIGH)


# ------------------------------------------------------------------------------


# Call this. The system has been split this way so that puavomenu only
# has to parse arguments and once it is one, import this file and run
# the menu. If you just run puavomenu from the command line, it tries
# to import all sorts of X libraries and stuff and sometimes that fails
# and you can't even see the help text!
def run():
    try:
        menu = PuavoMenu()
        setup_signal_handlers(menu)
        Gtk.main()

        # Normal exit, try to remove the socket file but don't explode
        # if it fails
        try:
            unlink(SETTINGS.socket)
        except OSError:
            pass

    except Exception as e:
        logger.traceback(traceback.format_exc())
