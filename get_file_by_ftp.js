// usage: var mod = require("./get_file_by_ftp");
//      : mod.get_file_by_ftp(path, res);

exports.get_file_by_ftp = function(path, res) {
  var fs = require("fs");
  var FTP = require("ftp");
  var client = new FTP();

  client.connect({
    host: "",
    port: 21,
    user: "",
    password: "",
  });

  client.on("ready", () => {
    // â‘ÎƒpƒXŽw’è(/dir/name.002 etc.)
    client.get("test/aaaa.txt", (error, stream) => {
      if (error) {
       throw error;
      }
      stream.once('close', function () { client.end(); });
      stream.pipe(fs.createWriteStream(`bbbb.txt`)).pipe(res);
      //res.end();
    });
  });
}
