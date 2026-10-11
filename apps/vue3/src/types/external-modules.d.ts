declare module 'markdown-it-abbr' {
  import type MarkdownIt from 'markdown-it'

  const plugin: MarkdownIt.PluginSimple
  export default plugin
}

declare module 'markdown-it-footnote' {
  import type MarkdownIt from 'markdown-it'

  const plugin: MarkdownIt.PluginSimple
  export default plugin
}

declare module 'markdown-it-sub' {
  import type MarkdownIt from 'markdown-it'

  const plugin: MarkdownIt.PluginSimple
  export default plugin
}

declare module 'markdown-it-sup' {
  import type MarkdownIt from 'markdown-it'

  const plugin: MarkdownIt.PluginSimple
  export default plugin
}

declare module 'markdown-it-task-lists' {
  import type MarkdownIt from 'markdown-it'

  const plugin: MarkdownIt.PluginWithOptions<Record<string, unknown>>
  export default plugin
}
