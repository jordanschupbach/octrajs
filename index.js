const octrajs = require("./build/Release/octrajs");

// Directly export everything from the octrajs import
module.exports = {
  ...octrajs,
};
