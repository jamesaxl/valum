[indent=2]
init
  var app = new Valum.Router ()

  app.get ("", home)

  new VSGI.HTTP.Server ("org.valum.example.Genie", app.handle).run ({"app", "--all"})

def home (req : VSGI.Request, res : VSGI.Response) : bool raises IOError
  return res.body.write_all ("Hello world!".data, null)
