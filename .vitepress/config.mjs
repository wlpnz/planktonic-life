import { defineConfig } from 'vitepress'
import { set_sidebar } from "../utils/auto-gen-sidebar.mjs";	// 改成自己的路径

export default defineConfig({
  title: "小小浮游",
  titleTemplate: ":title",
  description: "雾岚的笔记仓库",
  // base: `/planktonic-life/`,
  // head: [['link', { rel: 'icon', href: `/planktonic-life/favicon.svg` }]],
  head: [['link', { rel: 'icon', href: `/favicon.svg` }]],
  lang: 'zh-CN',
  lastUpdated: true,
  themeConfig: {
    outline: [2, 6],
    search: {
      provider: 'algolia',
      options: {
        appId: 'SZC32E2BED',
        apiKey: '96abed280a36c62cb1374434973050bd',
        indexName: 'wlpnz',
        placeholder: '请输入关键字'
      }
    },
    // search: {
    //   provider: 'local'
    // },
    nav: [
      { text: '首页', link: '/' },
      { text: '后端', link: '/backend' },
      { text: '前端', link: '/frontend' },
      { text: '数据库', link: '/database' },
      { text: '运维', link: '/operations' },
      { text: '面试', link: '/interview' },
      { text: '经验', link: '/project_exp' },
    ],
    sidebar:{
      "/backend": set_sidebar("/backend"),
      "/frontend": set_sidebar("/frontend"),
      "/database": set_sidebar("/database"),
      "/operations": set_sidebar("/operations"),
      "/interview": set_sidebar("/interview"),
      "/project_exp": set_sidebar("/project_exp")
    },
    logo: "plankton.svg", // 配置logo位置，public目录
    socialLinks: [
      { icon: 'github', link: 'https://github.com/wlpnz/planktonic-life' }
    ],
    footer: {
      message: '开发者笔记仓库',
      copyright: 'Copyright © 2024 雾岚'
    },
    docFooter: {
      prev: false,
      next: false
    }
  },
  sitemap: {
    hostname: 'https://blog.wlpnz.top/'
  }
})
