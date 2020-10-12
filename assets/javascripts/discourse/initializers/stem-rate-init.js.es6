import { withPluginApi } from 'discourse/lib/plugin-api'
import I18n from 'I18n'
import { ajax } from 'discourse/lib/ajax'
import showModal from 'discourse/lib/show-modal'
import { h } from 'virtual-dom'
import { renderIcon } from 'discourse-common/lib/icon-library'

const criteria = {
  'creativity': 1,
  'technicality': 3,
  'clarity': 2,
  'usefulness': 6,
}

export default {
  name: 'stem-rate-init',
  initialize: function(container) {
    withPluginApi('0.8.6', api => {

      Object.keys(criteria).forEach(section => {
        api.attachWidgetAction('post-menu', `rate${section}`, function() {
          this.state.visible = this.state.visible === section ? null : section
        })
      })

      api.reopenWidget('post-menu', {
        defaultState({ id, post_number }) {
          const state = this._super()

          if (this.currentUser && !state.rating && post_number === 1) {
            state.rating = {}
            ajax('/stem/rating/get.json', { type: 'GET', data: { post_id: id } }).then(({ rating }) => {
              state.rating = Object.entries(criteria).reduce((result, [key, id]) => {
                result[key] = rating[id].value
                return result
              }, {})
              this.scheduleRerender()
            })
          }

          return state
        },

        rate({ postId, section, stars }) {
          this.state.rating[section] = stars + 1
          this.state.visible = null
          ajax('/stem/rating/rate.json', {
            type: 'POST',
            data: {
              post_id: postId,
              criteria_ids: Object.keys(this.state.rating).map(k => criteria[k]),
              criteria_values: Object.values(this.state.rating),
            }
          })
        },

        html(attrs, state) {
          const html = this._super(attrs, state)
          if (
            !this.currentUser ||
            !html.length ||
            !html[0].children.length ||
            !html[0].children[0].children ||
            attrs.post_number > 1
          ) { return }

          Object.keys(criteria).forEach(section => (
            html[0].children[0].children.unshift(
              h('div.extra-buttons', this.attach('stem-rate-button', {
                section,
                postId: attrs.id,
                rating: this.state.rating[section],
                visible: this.state.visible,
              }))
            )
          ))

          return html
        }
      })

      api.createWidget('stem-rate-button', {
        html({ section, postId, rating, visible }) {
          return [
            this.attach('flat-button', {
              action: `rate${section}`,
              title: `stem_rating.${section}`,
              icon: `stem-rating-${section}`
            }),
            this.attach('stem-rate-stars', {
              visible: visible === section,
              section,
              postId,
              rating,
            }),
            rating ? h('span.stem-rate-current', `${rating}`) : ''
          ]
        }
      })

      api.createWidget('stem-rate-stars', {
        tagName: 'div.stem-rate-stars',

        buildClasses({ visible }) {
          return visible ? ['visible'] : []
        },

        html({ section, rating, postId }) {
          return [...Array(5)].map((_, stars) => (
            this.attach('stem-rate-star', { section, postId, stars, rating })
          ))
        }
      })

      api.createWidget('stem-rate-star', {
        tagName: 'div.stem-rate-star',

        buildClasses({ section, stars, rating }) {
          return rating > stars ? ['active'] : []
        },

        html({ rating }) {
          return renderIcon('node', 'stem-rating-star')
        },

        click() {
          this.sendWidgetAction('rate', this.attrs)
        }
      })
		})
  }
}
