class adm::users {
  include ::adm

  adm::user {
    # 1001 was reserved before

    'adm-juhaerk':
      sshkey      => 'AAAAB3NzaC1yc2EAAAABIwAAAQEAnlcriJylDCXUIy619nX/nBjDLaf4M668nz7HBFfwA2rlsbA48LPZ+gkUB2KgW6GUikT13djFo352HYQ2m3NJzNjTtk5hmZuGVb7eNmE5Q2/rr9D3vkEJN8qDDRsiKSk8nS3sya4pv7+BMe/4OoDV4ANvehd7svn3osqzHstQHvm+a6ycN8bqCsBYgj9is7PDnnoKA4XU6aOq13OfoB6XIZx3Q6qy745k976lOFOHVNtrUWJbUwz8OpDl3rU02Bc3P7a98BbuAwWp37AQSPg8Mhn8oXrUW/Dw5xeGVSVC1SFG4hEcEnF9gIYMY8WAYBzLOExPU/riOc/PnmX7vlJ/Zw==',
      sshkey_type => 'rsa',
      uid         => 1002;

    'adm-asokero':
      sshkey      => 'AAAAB3NzaC1yc2EAAAABIwAAAQEAoEsLAeV9AfZV4WOVXHIYyDvzHheQ7tagGWO7KsIYjTDDvxqOMMXgqVibRkoY3itqX2lI9e3pheD/7wC/abOx8Zzb0Qs5tKfCNe2U6CxOsN0cCEvcEZc3/ItsR0ynO5elT+DDRU3mF6zBahpZEq1mpPDDbNK/JziFOY+YSvphxn5iYQEOcuJPkiy4+kfuLH7HD5B/9h/Fa7x6IKWKzZR3vgqyD/xftZShN2ZklyQmxziq9+/bfMa/v8Ny8wuf4MO7mpEUWg3bAV0akqOqxm6nFtk0Fy7gmZObElZkmpldEnA39ALt16fncp8qvcW2U0FCgz0gHu3m2HeLBV3CU7ekpQ==',
      sshkey_type => 'rsa',
      uid         => 1003;

    'adm-cjoohs':
      sshkey      => 'AAAAB3NzaC1yc2EAAAABIwAAAQEAr8YO+0Ygwy592shekjeN6g+8f2TXY3Nt7eTV7u36eVQwLoy4+pThtVCKk1ei2u6cJi2AeKkIK/mWVkiju6OUTrMjsBIi3VBSUc+O8/cgi73SjuZjvRXuQUP27zFyoPLVbwk99K15upHJtV7FEIzfTretU6f5KssDjDyo/GJTSSL11R0HQWbGkSSAmEGqz1C965NJ4T78L3jLznf9bxkjClfpVaHXanEEvya3qay7izcBZT3k4R32hhTVzRhb2obt5BPguzkfz3jfG1/YfS8AjHTTJDz+uPdWVLpFdFB40TOkjgW6kQCq5c4VqAjeLYvo6lda9NP8HqHPm9pB39/MDQ==',
      sshkey_type => 'rsa',
      uid         => 1004;

    # 1005 was reserved before

    'adm-mjokinen':
      sshkey      => 'AAAAB3NzaC1yc2EAAAABIwAAAQEAvs4IP+ijmRvoE1x1mfbzaHXEd11czXQhVir/VtrEC4S6T9isqRwe1l+sKsrnlNp4X8qfqR7mPUuw/UoUAD2Zuk0zTtijxFVneqEEM4Q5KCo2WJrHt1DhvGdI9oBIQOFLLLJdX5sAq1JkVelrfVRSUtDCkKVLTj5pE+R7duYPdVO3804oO5GV2oroYfgDALf+Zt1YgfQuLeEw5ubu0hmk8Vf1RYmQBCiQPAcny0R5JbEWygugQJ5PVFYoi8Q7uYQzM1TJBy2xkZvJI/Yl3LJ9VO0ddh7hLaszAyT0O9YbmBbez3cmrukbPOzclmglmrSs2DuTtdZCrWNfiGrMORR38w==',
      sshkey_type => 'rsa',
      uid         => 1006;

    'adm-jokor':
      sshkey      => 'AAAAB3NzaC1yc2EAAAABIwAAAQEA3xr9LhWPstYx+FK2pndpaQZAAoT52uaTNrovayaNh41x593k4QQa4K1QIVTqlOaGNaq5NxFSQrYIMR53Jy2xRo88MD7o78KdqAl64kscD73DrA1Q1HpupS7ksMbnNkD5PB0mv2/+FBnWCXspGiEAHVSg3ARP3lBsWekgREox6r01C2ghPR6ZaGgB8K5cm9BEiXRmMvkWoPtxSLMGAdPS6mgzb6BoWUER6lf7sa/asDwNcAAwLLGf2ZICUpEzH+DaQrrV9wCxHcZvpk/pfnebjS7ld4x5NmXnmBWQt/qe6cDHRjYoyeeGEQFzWPaePN6ITf07/zBTLJHdY8UnyhtZDw==',
      sshkey_type => 'rsa',
      uid         => 1007;

    'adm-ptoivola':
      sshkey      => 'AAAAB3NzaC1yc2EAAAABIwAAAQEApIdhSUFOC5lbtyd+8duSn6Dt4wzLxz16Zfqwccsx3KXSDw5/tmhyRWAMcE5tTWOIiHW5Y5u7syJ9ZJS68FJLBx3o/I5SBIKiN32isyytqASsEU3mm+yS67yHU6/9bNGAN998YM9/Xk3CRJdgFn9nBGP9hRt+FCv6TBzB5NDOfW/tpkR76pPayiOUOAkrVAK3m0wrFi1/VwzdzTn/cRRBMUu/f/Gau7ZXaeBFP+WN5AM0OPWGvRFS3quTUelUVoWDrcWs2iwGpmTURUFqK48gWw4dWDv71ps/YB2cMsqbC3DDHecFa64ZgM+ui4mIwKaGO9+A8jaxOsjci9kQ7/9UTw==',
      sshkey_type => 'rsa',
      uid         => 1008;

    # 1009-1014 were reserved before

    'adm-jarmo':
      sshkey      => 'AAAAB3NzaC1yc2EAAAADAQABAAABAQCutK/dYF6XwVwW7e5d5ZJhGPZq4uvYyqGldFzstMGj/CkSZNVTwGwpTvvEMAU68I926kGXHiImVq30rFbac/U5cVg7SGsE726XJfN8a2+ayE9pCX6QvEGD0pJmdeIFTTFtDVuI+v0M5OdLX1eyyUX0g0bpw2DWl5J7jUufxKd1vh5zWuyaRy7F4uFAP2Jd2kkvuuB7rbzEOmwtkw7+cjm8U3TH78TOrBz1sW2DlOS8ih93wSQkRsCpWOZrSwA1nYr1TQff0k50iFR8wUqyuNB9YtS1tOlQsRGLH5S2fnBbzMmYtyU5yiFFikxuFSH0gaijJNk6EMAeQM17GYQdFQVr',
      sshkey_type => 'rsa',
      uid         => 1015;

    # 1016 was reserved before

    'adm-mlinna':
      sshkey      => 'AAAAB3NzaC1yc2EAAAADAQABAAABAQCwgOoKY1b+5nYiboF/nbGP7EzidpYAnv37mqshT022XRm2ZLYsM72J3pxGprQiGEvAufe5Kjn60SLnus3W2rYF6NRA9TkNuslh7dypZltAg4tCgLyFkJD6q0vctl2w1Vbwqnu6w603yU6gVBqWSO3PC7CkcfEzzp06riKmCGl+nhJ6gjHvYwZC4WVNT9/45n/lE20QLuzLgD60Rx0UIXNKgImpl5QCjdUI4nLf786Gc63J51ptPX9fL2U7VSJTJwEUlXD84bO8bVwOOU40/iZBCo5B9TL/syEunq2bqfxoha0PaYi8oSXx5JZf3OCmRUf//1C1kcHxrUbW/vVTcJgF',
      sshkey_type => 'rsa',
      uid         => 1017;

    'adm-tjousmaki':
      sshkey      => 'AAAAB3NzaC1yc2EAAAADAQABAAABAQC69Mjklxjd+99PofiCz53JZyJyQoFwI9T1jqmN423A8Od52ev0d0PPhFr02GaXEKZ2lvGgY+XYnib+aedxWY17775/9h1/JOs4jlKUSq2WyQLGYXl9QL8mXPMMzVqPwhCuayt/G5V23meA85gcyqKVGKKN5uiflHum5dXooPrUGUdOGPB4XMASFJOor8sYeh07GrzQ8RCWVfAyH6PYoi5pGbHQYGYZPhW1Bg1sx4B/hJIMIOS4iSa3dtyhAkV1HrjZcwoJ7I8fTCkYVanNzWAhBSgprpj5RKpWd51LkIPAO9jIuHaiz5M2uMstFP1PkB4aNw7fib3gxy03Swe+HWa5',
      sshkey_type => 'rsa',
      uid         => 1018;

    'adm-eranta':
      sshkey      => 'AAAAB3NzaC1yc2EAAAADAQABAAABAQC6Lh/QdR7lAEDg5Je6lzjxEUcONiF9U9+Rn8LcKBgK3uHo2cx9EO5iFOwd5Cfe8t0k20RFxGBCVqyRmTTVZXdCG9On1PijG7YeEU3NOBVgGDbKtwBdyrucMKDPmnTca+YcCH8dO01IAHc2esDqMc8mHloJ/WR45AxQ8/bZVQqZYKNdWXPDgPqusj7E+Hg2uog7Eo2eNJP0jf7aSS4YYpUVOxvJ/cTEbFWO3VL4Lgb1/IJep/Q6QwpmAS8K24thFbiN51C7VbFHPX58nDIjI/Hh0qXbFCatfR1RtnRHaY0IPhoffUBNhleAyNbIvN8sWjEVA6dIWAxdn4/2djokEoO5',
      sshkey_type => 'rsa',
      uid         => 1019;

    'adm-hniininen':
      sshkey      => 'AAAAB3NzaC1yc2EAAAADAQABAAABAQDCCJM2LHlwUb8LZWfIvgS71okWcc4Lts/P2qBqB1IqzAyp70vo/4m32RSkEKY2q8c1frvaznGVqlodkDkUKa0qQaWmzgQHWh1k74K7VIXRLsZS/Eh5gyUkvMDQGz8akwWt2nQw9Opw/Xa5cJ+uAYSIyE2exK3CQg9ToGbMyNI0M7UbxJu/Tk4v6rP0gTVWLg1drl53Nz8rlLvHdgpCpk2jLpi4eXzw5/epNWKL79j1KC2S+jR2pevaVJO9PTjZP9GaH4AgFuq/r3M6Rm6m6NhM5pfWDBEzUIv8FBIf8DjGJT/3erfBY0OKZ+M4kjt7UAl12iQ4Jqpou2ckxG2PeULr',
      sshkey_type => 'rsa',
      uid         => 1020;

    'adm-jmv1':
      sshkey      => 'AAAAB3NzaC1yc2EAAAADAQABAAABAQDWsxQcT2jJ9i2INUtvuakt0LPGR0CJaY9Es1VzWN4lbhLI2JCZGzXEBd72NE0N7td3nRPlfEeuaIzDiqnqOh8RdPfq9gn1G+0PvqE2hOPv/Oy21dRVuepV21cFLfVS47fzOp1KwHaNGT+69OAAzKA0dbiQ/Ewm0f/WHg1t5qoHaWp3JVouAxmXNRwQbg5zQ4BQSZzjmTgVdINB9xCb6VOB5RKsc1kIVvAGo0SgS+vFRc8bOP/wIA5Ao9nNhwyv/+r3Vet+NXXmeOiiQ7S9FH1ES58MYRqDmtNCZc7wFLNACtRW/YdfgGp6WMiXOuF5ihVUzwHObHgrxoFdSZae6/Wl',
      sshkey_type => 'rsa',
      uid         => 1021;
  }
}
