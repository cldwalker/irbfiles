module MathLib
  # Calculates the +nth+ root of a +x+.
  def root(x, n=2)
    x ** (1.0 / n)
  end

  #from http://www.elctech.com/snippets/convert-filesize-bytes-to-readable-string-in-javascript
  # Converts bytes to human readable bytes i.e. kb + MB
  def human_bytes(bytes)
    s = ['bytes', 'kb', 'MB', 'GB', 'TB', 'PB'];
    #indicates if thousands, millions ...
    place = (Math.log(bytes)/Math.log(1024)).floor
    (bytes/(1024 ** place.floor)).to_s+" "+s[place];
  end
end