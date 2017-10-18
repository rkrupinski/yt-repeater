const { resolve } = require('path');
const webpack = require('webpack');
const HtmlWebpackPlugin = require('html-webpack-plugin');
const CleanWebpackPlugin = require('clean-webpack-plugin');
const MinifyPlugin = require('babel-minify-webpack-plugin');

const TARGET = process.env.npm_lifecycle_event;

module.exports = {
  entry: resolve(__dirname, 'src', 'app.js'),

  output: {
    path: resolve(__dirname, 'build'),
    filename: TARGET === 'start' ? '[name].js' : '[name]-[hash:8].js',
  },

  resolveLoader: {
    modules: [
      'node_modules',
      resolve(__dirname, 'loaders'),
    ],
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
          /Stylesheets\.elm$/,
        ],
        use: [
          TARGET === 'start' ? 'elm-hot-loader' : 'identity-loader',
          {
            loader: 'elm-assets-loader',
            options: {
              module: 'Assets',
              tagger: 'AssetPath',
              package: 'rkrupinski/yt-repeater',
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
      {
        test: /Stylesheets\.elm$/,
        use: [
          'style-loader',
          'css-loader',
          'elm-css-webpack-loader',
        ],
      },
    ],
  },

  devServer: {
    contentBase: resolve(__dirname, 'build'),
    hot: true,
    open: true,
    inline: true,
    port: 8001,
    publicPath: '/',
  },

  plugins: TARGET === 'start' ?
      [
        new webpack.HotModuleReplacementPlugin(),
        new webpack.NamedModulesPlugin(),
        new HtmlWebpackPlugin({
          title: 'YouTube repeater',
        }),
      ] :
      [
        new CleanWebpackPlugin([
          resolve(__dirname, 'build'),
        ]),
        new MinifyPlugin(),
        new webpack.optimize.ModuleConcatenationPlugin(),
        new HtmlWebpackPlugin({
          title: 'YouTube repeater',
          minify: {
            collapseWhitespace: true,
          },
        }),
      ],

  devtool: TARGET === 'start' ? 'cheap-module-eval-source-map' : undefined,
};
