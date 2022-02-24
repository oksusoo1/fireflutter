module.exports = {
  root: true,
  env: {
    es6: true,
    node: true,
    mocha: true,
  },
  extends: ["eslint:recommended", "google"],
  rules: {
    "max-len": "off",
    "valid-jsdoc": "off",
    "require-jsdoc": "off",
    "quotes": ["error", "double"],
  },
  parserOptions: {
    // ecmaVersion: 8, // or 2017
    ecmaVersion: 2020,
  },
};
