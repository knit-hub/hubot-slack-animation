# hubot-slack-animation

![hubot-slack-animation](http://cdn-ak.f.st-hatena.com/images/fotolife/k/knithub/20170215/20170215205727.gif)

Make animation message such as emoji on Slack powerd by [hubot](https://github.com/github/hubot) with [hubot-slack](https://github.com/slackhq/hubot-slack).

See [`src/index.coffee`](src/index.coffee) for usage.

## Installation

In hubot project repo, install this module.

```sh
npm install --save hubot-slack-animation
```

And export some vars.

```sh
export MIN_UPDATE_INTERVAL=0.1
export MAX_ANIMATION_LENGTH=60
```

Then add **hubot-slack-animation** to your `external-scripts.json`.

```json
[
 "hubot-slack-animation"
]
```

# LICENSE
MIT.
