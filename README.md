# Bingosync

[![Build Status](http://drone.mdel.io/api/badges/mdeltito/bingosync/status.svg)](http://drone.mdel.io/mdeltito/bingosync)
[![Development Status](https://img.shields.io/badge/Development%20Status-Inactive-red.svg)](https://img.shields.io/badge/Development%20Status-Inactive-red.svg)

## About

Bingosync is a real-time bingo board application used to enhance game play for team-style games. It is designed to work with the official [SRL](http://speedrunslive.com) bingo boards, as well as derivatives.

[![Screenshot](https://i.imgur.com/lHDDFW3.png)](https://i.imgur.com/lHDDFW3.png)

## History

This project is the "original" Bingosync, which was developed in 2013 to support team-style bingo games for the speedrunning community. The project was mostly abandoned in early 2015.

[Bingosync.com](http://bingosync.com) emerged soon after, and is a (much improved) rebuild of the original concept. This project is unaffiliated with [bingosync.com](http://bingosync.com), but be sure to check out that version!

## Requirements

### Running with Docker

The included Docker configuration has all the necessary dependencies and a separate Redis container for caching. If you run the project with Docker, the only requirements are:

- Docker
- Docker Compose (1.10+)

### Standalone

- Node.js (4.x)
- Bower
- Grunt
- Puppeteer

## Quick Start

```
docker-compose up
```
