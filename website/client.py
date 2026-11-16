import urllib.request,ssl,sys
ctx=ssl.create_default_context(cafile='cert.pem')
url=sys.argv[1]
req=urllib.request.Request(url,data=b'username=student-demo&password=ProjectOnly-381',headers={'Content-Type':'application/x-www-form-urlencoded'})
print(url,urllib.request.urlopen(req,context=ctx).read().decode())
