import Vue from 'vue'
import 'normalize.css/normalize.css'
import '@/styles/index.scss'
import ElementUI from 'element-ui'
import 'element-ui/lib/theme-chalk/index.css'
import CommonPlugin from './utils/common-plugin'
import App from './App'
import store from './store'
import router from './router'
import i18n from './lang'
import '@/icons' // icon
import '@/permission'

/**
 * If you don't want to use mock-server
 * you want to use MockJs for mock api
 * you can execute: mockXHR()
 *
 * Currently MockJs will be used in the production environment,
 * please remove it before going online! ! !
 */
import { mockXHR } from '../mock'
if (process.env.NODE_ENV === 'development') {
  mockXHR()
}

Vue.use(ElementUI, { size: 'small', zIndex: 5000, i18n: (key, value) => i18n.t(key, value) })
Vue.use(CommonPlugin)

Vue.config.productionTip = false

new Vue({
  el: '#app',
  router,
  store,
  i18n,
  render: h => h(App)
})
