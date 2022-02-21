module.exports = {
  root: true,
  env: {
    es6: true,
    node: true,
  },
  extends: [
    "eslint:recommended",
    "google",
  ],
  rules: {
    "max-len": "off",
    "quotes": ["error", "double"],
  },
  parserOptions: {
    ecmaVersion: 8, // or 2017
  },
};
