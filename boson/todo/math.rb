#from http://www.elctech.com/snippets/convert-filesize-bytes-to-readable-string-in-javascript  
def human_bytes(bytes)
  s = ['bytes', 'kb', 'MB', 'GB', 'TB', 'PB'];
  #indicates if thousands, millions ...
  place = (Math.log(bytes)/Math.log(1024)).floor
  (bytes/Math.pow(1024, Math.floor(e))).toFixed(2)+" "+s[e];
  #var e = Math.floor(Math.log(bytes)/Math.log(1024));
  #return (bytes/Math.pow(1024, Math.floor(e))).toFixed(2)+" "+s[e];
end

