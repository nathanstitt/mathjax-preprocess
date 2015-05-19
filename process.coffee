mj    = require 'MathJax-node'
fs    = require 'fs'
jsdom = require('jsdom').jsdom

processHTML = (html, cb) ->
  doc = jsdom(html,{features:{FetchExternalResources: false}})
  nodes = doc.querySelectorAll('[data-math]') or []
  for node in nodes
    formula = node.getAttribute('data-math')
    # Divs with data-math should be rendered as a block
    if node.tagName.toLowerCase() in ['div']
      node.textContent = "$$#{formula}$$"
    else
      node.textContent = "$#{formula}$"

  mj.typeset({
    html: doc.body.innerHTML,
    renderer: "SVG"
  }, (result) ->
    cb(result.html)
  )

html = []
process.stdin.on("readable",  (block) ->
  chunk = process.stdin.read()
  html.push(chunk.toString('utf8')) if chunk
)

process.stdin.on("end", ->
  processHTML(html.join(""), (processed) ->
    process.stdout.write(processed)
  )
)
