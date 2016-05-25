var path = require('path')
var fs = require('fs')

console.log(__filename)

// change this to your path to modelAll.
var modelAll = path.resolve('./src-gen/modelAll/')
if (fs.existsSync(modelAll)) {
  // all we care is that they have been pre-loaded
  try {
    require(modelAll)
  } catch (e) {
    console.log(e.stack)
  }
}

var types = path.resolve(path.join('conversations', 'types'))

module.exports = function () {
  if (fs.existsSync(types)) {
    require(types)
  }
}
