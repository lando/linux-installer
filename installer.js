const { exec } = require('child_process');


const install = () => {
  exec("sh ./scripts/preflight-checks.sh", (error, stdout) => {
    if (error) {
      console.log(error)
    }
    console.log(stdout);
  });
}

module.exports = {
  install,
};