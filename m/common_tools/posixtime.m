function t = posixtime()
%POSIXTIME  Current POSIX time using low level utilities.
%
%  T = POSIXTIME() returns the current POSIX time: the number of seconds since
%  1970-01-01 00:00:00 UTC, not counting the effects of leap seconds.
%
%  Notes:
%    This function provides a compatibility interface for MATLAB and Octave,
%    computing the POSIX time using lower level tools available in each system:
%    In MATLAB, through the Java function JAVA.LANG.SYSTEM.CURRENTTIMEMILLIS.
%    In Octave, through the built-in ANSI C function TIME.    
%
%  Examples:
%    t = posixtime()
%    datestr(posixtime2utc(t))
%    datestr(now())
%    
%
%  See also:
%    POSIXTIME2UTC
%    UTC2POSIXTIME
%
%  Author: Joan Pau Beltran
%  Email: joanpau.beltran@socib.cat

  error(nargchk(0, 0, nargin, 'struct'));
  
  % Consider making the variable persistent
  % (the needed emptiness check may be more expensive than the existence check).
  ISOCTAVE = exist('OCTAVE_VERSION','builtin');

  if ISOCTAVE
    t = time();
  else
    t = 1e-3 * java.lang.System.currentTimeMillis();
  end

end
