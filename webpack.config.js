const { resolve } = require('path');
const webpack = require('webpack');
const HtmlWebpackPlugin = require('html-webpack-plugin');

module.exports = {
  entry: resolve(__dirname, 'src', 'app.js'),

  output: {
    path: resolve(__dirname, 'build'),
    filename: '[name].js',
    publicPath: '/',
  },

  resolve: {
    extensions: [
      '.js',
      '.elm',
    ],
    modules: [
      resolve(__dirname, 'assets'),
      resolve(__dirname, 'src'),
      resolve(__dirname, 'elm'),
      'node_modules',
    ],
  },

  module: {
    loaders: [
      {
        test: /\.elm$/,
        exclude: [
          /elm-stuff/,
          /node_modules/,
        ],
        use: [
          'elm-hot-loader',
          {
            loader: 'elm-assets-loader',
            options: {
              module: 'Assets',
              tagger: 'AssetPath',
            },
          },
          'elm-webpack-loader',
        ],
      },
      {
        test: /\.(jpe?g|png|gif|svg)$/i,
        loader: 'file-loader',
        options: {
          name: '[name]-[hash:8].[ext]',
        },
      },
    ],
  },

  devServer: {
    contentBase: resolve(__dirname, 'build'),
    hot: true,
    open: true,
    inline: true,
    publicPath: '/',
  },

  plugins: [
    new webpack.HotModuleReplacementPlugin(),
    new webpack.NamedModulesPlugin(),
    new HtmlWebpackPlugin({
      title: 'YouTube repeater',
    }),
  ],

  devtool: 'cheap-module-eval-source-map',
};
