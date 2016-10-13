/* puavo-conf-update
 * Copyright (C) 2016 Opinsys Oy
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 */

#define _GNU_SOURCE

#include <sys/types.h>
#include <sys/mman.h>
#include <sys/stat.h>

#include <err.h>
#include <fcntl.h>
#include <getopt.h>
#include <glob.h>
#include <jansson.h>
#include <stdio.h>
#include <string.h>
#include <unistd.h>

#include "conf.h"

#define DEVICEJSON_PATH "/etc/puavo/device.json"

char *puavo_hosttype;

static int	 apply_device_settings(puavo_conf_t *, const char *, int);
static int	 apply_hosttype_profile(puavo_conf_t *, const char *, int);
static int	 apply_hwquirks(puavo_conf_t *, int);
static int	 apply_kernel_arguments(puavo_conf_t *, char *, int);
static char	*get_cmdline(void);
static char	*get_puavo_hosttype(const char *);
static int	 overwrite_value(puavo_conf_t *, const char *, const char *,
    int);
static json_t	*parse_json_file(const char *);
static int	 update_puavoconf(puavo_conf_t *, const char *, int);
static void	 usage(void);

int
main(int argc, char *argv[])
{
	puavo_conf_t *conf;
	struct puavo_conf_err err;
	const char *device_json_path;
	static struct option long_options[] = {
	    { "devicejson-path", required_argument, 0, 0 },
	    { "help",            no_argument,       0, 0 },
	    { "verbose",         no_argument,       0, 0 },
	};
	int c, option_index, status, verbose;

	status = 0;
	verbose = 0;

	device_json_path = DEVICEJSON_PATH;

	for (;;) {
		option_index = 0;
		c = getopt_long(argc, argv, "", long_options, &option_index);
		if (c == -1)
			break;

		if (c != 0) {
			usage();
			return 1;
		}

		switch (option_index) {
		case 0:
			device_json_path = optarg;
			break;
		case 1:
			usage();
			return 0;
		case 2:
			verbose = 1;
			break;
		default:
			usage();
			return 1;
		}
	}

	if (optind < argc) {
		usage();
		return 1;
	}

	if (puavo_conf_open(&conf, &err))
		errx(1, "Failed to open config backend: %s", err.msg);

	if (update_puavoconf(conf, device_json_path, verbose) != 0) {
		warnx("problem in updating puavoconf");
		status = EXIT_FAILURE;
	}

	if (puavo_conf_close(conf, &err) == -1) {
		warnx("Failed to close config backend: %s", err.msg);
		status = EXIT_FAILURE;
	}

	return status;

	return 0;
}

static void
usage(void)
{
	printf("Usage:\n"
	       "    puavo-conf-update [OPTION]...\n"
	       "\n"
	       "Update configuration database by overwriting parameter values\n"
	       "from the following sources, in the given order:\n"
	       "\n"
	       "  1. hardware quirks\n"
	       "  2. device specific settings from " DEVICEJSON_PATH "\n"
	       "  3. kernel command line\n"
	       "\n"
	       "Options:\n"
	       "  --help, -h                display this help and exit\n"
	       "\n"
	       "  --devicejson-path FILE    filepath of the device.json,\n"
	       "                            defaults to " DEVICEJSON_PATH "\n"
	       "\n");
}

static int
update_puavoconf(puavo_conf_t *conf, const char *device_json_path, int verbose)
{
	char *cmdline;
	char *hosttype;
	int ret;

	ret = 0;

	cmdline = get_cmdline();
	if (cmdline == NULL) {
		warnx("could not read /proc/cmdline");
		ret = 1;
	}

	hosttype = NULL;
	if (cmdline != NULL)
		hosttype = get_puavo_hosttype(cmdline);

	if (hosttype != NULL) {
		if (apply_hosttype_profile(conf, hosttype, verbose) != 0) {
			warnx("could not apply hosttype profile %s", hosttype);
			ret = 1;
		}
	} else {
		warnx("skipping hosttype profile because hosttype not known");
		ret = 1;
	}

	if (apply_hwquirks(conf, verbose) != 0)
		ret = 1;

	if (apply_device_settings(conf, device_json_path, verbose) != 0)
		ret = 1;

	if (cmdline != 0) {
		if (apply_kernel_arguments(conf, cmdline, verbose) != 0)
			ret = 1;
	} else {
		warnx("skipping kernel arguments because those are not known");
		ret = 1;
	}

	free(cmdline);
	free(hosttype);

	return ret;
}

static char *
get_puavo_hosttype(const char *cmdline)
{
	char *cmdarg, *cmdline_copy, *cmdline_iter, *hosttype;
	size_t prefix_len;

	hosttype = NULL;

	if ((cmdline_copy = strdup(cmdline)) == NULL) {
		warn("strdup() error in get_puavo_hosttype()");
		return NULL;
	}

	prefix_len = sizeof("puavo.hosttype=") - 1;

	cmdline_iter = cmdline_copy;
	while ((cmdarg = strsep(&cmdline_iter, " \t\n")) != NULL) {
		if (strncmp(cmdarg, "puavo.hosttype=", prefix_len) != 0)
			continue;

		hosttype = strdup(&cmdarg[prefix_len]);
		if (hosttype == NULL)
			warn("strdup() error in get_puavo_hosttype()");
		break;
	}

	if (hosttype == NULL)
		warnx("could not determine puavo hosttype");

	free(cmdline_copy);

	return hosttype;
}

static char *
get_cmdline(void)
{
	FILE *cmdline;
	char *line;
	size_t n;

	if ((cmdline = fopen("/tmp/cmdline", "r")) == NULL) {
		warn("fopen /proc/cmdline");
		return NULL;
	}

	line = NULL;
	n = 0;
	if (getline(&line, &n, cmdline) == -1) {
		warn("getline() on /proc/cmdline");
		free(line);
		return NULL;
	}

	(void) fclose(cmdline);

	return line;
}

static int
apply_device_settings(puavo_conf_t *conf, const char *device_json_path,
    int verbose)
{
	/* XXX */
	return 0;
}

static int
apply_hosttype_profile(puavo_conf_t *conf, const char *hosttype, int verbose)
{
	json_t *root, *node_value;
	const char *param_name, *param_value;
	char *hosttype_profile_path;
	int ret, retvalue;

	retvalue = 0;
	root = NULL;

	ret = asprintf(&hosttype_profile_path,
	    "/usr/share/puavo-conf/profile-overwrites/%s.json",
	    hosttype);
	if (ret == -1) {
		warnx("asprintf() error in apply_hosttype_profile()");
		return 1;
	}

	if ((root = parse_json_file(hosttype_profile_path)) == NULL) {
		warnx("parse_json_file() failed");
		retvalue = 1;
		goto finish;
	}

	if (!json_is_object(root)) {
		warnx("hosttype profile %s is not in correct format",
		    hosttype_profile_path);
		retvalue = 1;
		goto finish;
	}

	json_object_foreach(root, param_name, node_value) {
		if ((param_value = json_string_value(node_value)) == NULL) {
			warnx("hosttype profile %s has a non-string value",
			    hosttype_profile_path);
			retvalue = 1;
			continue;
		}
		ret = overwrite_value(conf, param_name, param_value, verbose);
		if (ret != 0)
			retvalue = 1;
	}

finish:
	if (root != NULL)
		json_decref(root);

	free(hosttype_profile_path);

	return retvalue;
}

static int
apply_hwquirks(puavo_conf_t *conf, int verbose)
{
	/* XXX */
	return 0;
}

static int
apply_kernel_arguments(puavo_conf_t *conf, char *cmdline, int verbose)
{
	char *cmdarg, *param_name, *param_value;
	size_t prefix_len;
	int ret, retvalue;

	retvalue = 0;

	prefix_len = sizeof("puavo.") - 1;

	while ((cmdarg = strsep(&cmdline, " \t\n")) != NULL) {
		if (strncmp(cmdarg, "puavo.", prefix_len) != 0)
			continue;

		param_value = cmdarg;
		param_name = strsep(&param_value, "=");
		if (param_value == NULL)
			continue;

		ret = overwrite_value(conf, param_name, param_value, verbose);
		if (ret != 0)
			retvalue = 1;
	}

	return retvalue;
}

static int
overwrite_value(puavo_conf_t *conf, const char *key, const char *value,
    int verbose)
{
	struct puavo_conf_err err;
	int ret;

	ret = puavo_conf_overwrite(conf, key, value, &err);

	if (ret != 0) {
		warnx("error overwriting %s --> %s : %s", key, value, err.msg);
	} else if (verbose) {
		(void) printf("puavo-conf-update: setting puavo conf key %s"
		    " --> %s\n", key, value);
	}
}

static json_t *
parse_json_file(const char *filepath)
{
	json_t *root;
	json_error_t error;
	const char *json;
	off_t len;
	int fd;

	root = NULL;

	if ((fd = open(filepath, O_RDONLY)) == -1) {
		warn("open() on %s", filepath);
		return NULL;
	}

	if ((len = lseek(fd, 0, SEEK_END)) == -1) {
		warn("lseek() on %s", filepath);
		goto finish;
	}

	if ((json = mmap(0, len, PROT_READ, MAP_PRIVATE, fd, 0)) == NULL) {
		warn("mmap() on %s", filepath);
		goto finish;
	}

	if ((root = json_loads(json, 0, &error)) == NULL) {
		warnx("error parsing json file %s line %d: %s", filepath,
		    error.line, error.text);
	}

finish:
	(void) close(fd);

	return root;
}

#if 0

  #!/usr/bin/ruby

require 'getoptlong'
require 'json'

require 'puavo/conf'

def apply_parameter_filters(parameters, parameter_filters, lookup_fn)
    parameter_filters.each do |filter|
        validate_parameter_filter(filter)

        if filter['key'] == '*' then
            parameters.update(filter['parameters'])
            next
        end

        parameter_values = lookup_fn.call(filter['key'])
        next if parameter_values.nil?

        parameter_values.each do |value|
            match_result = match_puavopattern(value,
                                              filter['matchmethod'],
                                              filter['pattern'])
            if match_result then
                parameters.update(filter['parameters'])
                break
            end
        end
    end
end

def validate_value(value)
    return true if value.kind_of?(String)
    raise "Value has unsupported type"
end

def validate_parameter_filter(obj)
    unless obj.kind_of?(Hash)
        raise "Parameter filters must be an hash"
    end
    %w(key matchmethod pattern parameters).each do |required_key|
        unless obj.has_key?(required_key)
            raise "Parameter filter is missing required key '#{required_key}'"
        end
    end
    unless obj['key'].kind_of?(String)
        raise "Parameter filter's key is of wrong type"
    end
    unless %w(exact glob regex).include?(obj['matchmethod'])
        raise "Parameter filter's matchmethod has unknown value"
    end
    unless obj['pattern'].kind_of?(String)
        raise "Parameter filter's pattern is of wrong type"
    end
    unless obj['parameters'].kind_of?(Hash)
        raise "Parameter filter's parameters is of wrong type"
    end
    if obj['parameters'].empty?
        raise "Parameter filter's parameters is empty"
    end
    obj['parameters'].each do |key, value|
        unless key.kind_of?(String)
            raise "Parameter key must be a string"
        end
        validate_value(value)
    end
    true
end

def read_json_obj(file, type)
    obj = JSON.parse(IO.read(file))
    unless obj.kind_of?(type)
        raise "Top-level JSON object of #{file} is not #{type}"
    end
    obj
end

$deviceinfo = {}
def get_device_setting(key)
    # returns nil in case there was a failure
    return $deviceinfo[key] if $deviceinfo.has_key?(key)

    case key
        when 'dmidecode-baseboard-asset-tag',
             'dmidecode-baseboard-manufacturer',
             'dmidecode-baseboard-product-name',
             'dmidecode-baseboard-serial-number',
             'dmidecode-baseboard-version',
             'dmidecode-bios-release-date',
             'dmidecode-bios-vendor',
             'dmidecode-bios-version',
             'dmidecode-chassis-asset-tag',
             'dmidecode-chassis-manufacturer',
             'dmidecode-chassis-serial-number',
             'dmidecode-chassis-type',
             'dmidecode-chassis-version',
             'dmidecode-processor-family',
             'dmidecode-processor-frequency',
             'dmidecode-processor-manufacturer',
             'dmidecode-processor-version',
             'dmidecode-system-manufacturer',
             'dmidecode-system-product-name',
             'dmidecode-system-serial-number',
             'dmidecode-system-uuid',
             'dmidecode-system-version'
                cmdarg = key[ "dmidecode-".length .. -1]
                result = %x(dmidecode -s #{ cmdarg })
                status = $?.exitstatus
                if status != 0 then
                    logerr("dmidecode -s #{ cmdarg } returned #{ status }")
                    $deviceinfo[key] = nil
                else
                    $deviceinfo[key] = [ result.strip ]
                end
        when 'pci-id'
            # might return nil, that is okay
            $deviceinfo[key] = take_field('lspci -n', 3)
        when 'usb-id'
            # might return nil, that is okay
            $deviceinfo[key] = take_field('lsusb', 6)
        else
            logerr("Unknown device key #{ key }")
            $deviceinfo[key] = nil
    end

    return $deviceinfo[key]
end

def logwarn(msg)
    warn("Warning: #{msg}")
end

def logerr(msg)
    warn("Error: #{msg}")
    $status = 1
end

def match_puavopattern(target, matchmethod, pattern)
    # XXX if 'logic' matchmethod is going to be implemented
    # XXX pattern might not be a string?
    if !pattern.kind_of?(String) then
        logerr('input type error: match pattern is not a string')
        return
    end

    case matchmethod
        when 'exact'
            return target == pattern
        when 'glob'
            return File.fnmatch(pattern, target)
        when 'logic'
            logerr("Match method logic not implemented yet")
            return false
        when 'regex'
            return target.match(pattern) ? true : false
        else
            logerr("Match method #{ matchmethod } is unsupported")
    end

    return false
end

def take_field(cmd, fieldnum)
    result = %x(#{ cmd })
    status = $?.exitstatus
    if status != 0 then
        logerr("#{ cmd } returned #{ status }")
        return nil
    end

    result.split("\n").map { |line| (line.split(' '))[fieldnum-1] }
end

def usage()
    puts <<-EOF
Usage:
    puavo-conf-update [OPTION]...

Update configuration database by overwriting parameter values from the
following sources, in the given order:

  1. hardware quirks
  2. device specific settings from '#{$devicejson_path}'
  3. kernel command line

Options:
  --help, -h                  display this help and exit

  --devicejson-path FILE      filepath of the device.json, defaults to
                              '#{$devicejson_path}'

EOF
end

def get_hwquirk_params()
    parameters = {}
    files      = Dir.glob('/usr/share/puavo-conf/hwquirk-overwrites/*.json') rescue []

    files.each do |file|
        apply_parameter_filters(parameters,
                                read_json_obj(file, Array),
                                Proc.method(:get_device_setting))
    end

    return parameters
end

def get_devicejson_params()
    begin
        device = read_json_obj($devicejson_path, Hash)
    rescue Errno::ENOENT
        return {}
    end
    device['conf'] or {}
end

def get_kernelarg_params()
    parameters = {}

    IO.read('/proc/cmdline').split.each do |kernel_arg|
        if kernel_arg =~ /\A(puavo\..*)=(.*)\Z/
            parameters[$1] = $2
        end
    end

    return parameters
end

def get_profile_params(profile)
    return {} if profile.nil?

    begin
        read_json_obj("/usr/share/puavo-conf/profile-overwrites/#{profile}.json", Hash)
    rescue Errno::ENOENT
        {}
    end
end

  ## Main

$status = 0

$devicejson_path = '/etc/puavo/device.json'

begin
    opts = GetoptLong.new(['--help', '-h',      GetoptLong::NO_ARGUMENT],
                          ['--devicejson-path', GetoptLong::REQUIRED_ARGUMENT])

    opts.each do |opt, arg|
        case opt
            when '--help'
                usage
                exit 0
            when '--devicejson-path'
                $devicejson_path = arg
        end
    end

rescue GetoptLong::InvalidOption => e
    usage
    exit 1
end

params = {}

hwquirk_params    = get_hwquirk_params
devicejson_params = get_devicejson_params
kernelarg_params  = get_kernelarg_params
profile_params    = get_profile_params(kernelarg_params.delete('puavo.hosttype'))

params.update(profile_params)
params.update(hwquirk_params)
params.update(devicejson_params)
params.update(kernelarg_params)

puavoconf = Puavo::Conf.new()
begin
    params.each do |key, value|
        begin
            puavoconf.overwrite(key, value)
        rescue StandardError => e
            logerr("Failed to overwrite a parameter: " \
                   "#{key}=#{value}: #{e.message}")
        end
    end
ensure
    puavoconf.close
end

exit($status)

#endif
