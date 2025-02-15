! function () {
	"use strict";
	var e = "undefined" != typeof window && void 0 !== window.document ? window.document : {},
	  n = "undefined" != typeof module && module.exports,
	  r = "undefined" != typeof Element && "ALLOW_KEYBOARD_INPUT" in Element,
	  l = function () {
		for (var n, r = [
			["requestFullscreen", "exitFullscreen", "fullscreenElement", "fullscreenEnabled", "fullscreenchange", "fullscreenerror"],
			["webkitRequestFullscreen", "webkitExitFullscreen", "webkitFullscreenElement", "webkitFullscreenEnabled", "webkitfullscreenchange", "webkitfullscreenerror"],
			["webkitRequestFullScreen", "webkitCancelFullScreen", "webkitCurrentFullScreenElement", "webkitCancelFullScreen", "webkitfullscreenchange", "webkitfullscreenerror"],
			["mozRequestFullScreen", "mozCancelFullScreen", "mozFullScreenElement", "mozFullScreenEnabled", "mozfullscreenchange", "mozfullscreenerror"],
			["msRequestFullscreen", "msExitFullscreen", "msFullscreenElement", "msFullscreenEnabled", "MSFullscreenChange", "MSFullscreenError"]
		  ], l = 0, t = r.length, u = {}; l < t; l++)
		  if ((n = r[l]) && n[1] in e) {
			for (l = 0; l < n.length; l++) u[r[0][l]] = n[l];
			return u
		  } return !1
	  }(),
	  t = {
		change: l.fullscreenchange,
		error: l.fullscreenerror
	  },
	  u = {
		request: function (n) {
		  return new Promise(function (t) {
			var u = l.requestFullscreen,
			  c = function () {
				this.off("change", c), t()
			  }.bind(this);
			n = n || e.documentElement, / Version\/5\.1(?:\.\d+)? Safari\//.test(navigator.userAgent) ? n[u]() : n[u](r ? Element.ALLOW_KEYBOARD_INPUT : {}), this.on("change", c)
		  }.bind(this))
		},
		exit: function () {
		  return new Promise(function (n) {
			var r = function () {
			  this.off("change", r), n()
			}.bind(this);
			e[l.exitFullscreen](), this.on("change", r)
		  }.bind(this))
		},
		toggle: function (e) {
		  return this.isFullscreen ? this.exit() : this.request(e)
		},
		onchange: function (e) {
		  this.on("change", e)
		},
		onerror: function (e) {
		  this.on("error", e)
		},
		on: function (n, r) {
		  var l = t[n];
		  l && e.addEventListener(l, r, !1)
		},
		off: function (n, r) {
		  var l = t[n];
		  l && e.removeEventListener(l, r, !1)
		},
		raw: l
	  };
	l ? (Object.defineProperties(u, {
	  isFullscreen: {
		get: function () {
		  return Boolean(e[l.fullscreenElement])
		}
	  },
	  element: {
		enumerable: !0,
		get: function () {
		  return e[l.fullscreenElement]
		}
	  },
	  enabled: {
		enumerable: !0,
		get: function () {
		  return Boolean(e[l.fullscreenEnabled])
		}
	  }
	}), n ? module.exports = u : window.screenfull = u) : n ? module.exports = !1 : window.screenfull = !1
  }();
