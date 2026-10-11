<script lang="ts" setup>
import { useAsyncState } from '@vueuse/core'
import type { RouteLocationNormalizedLoaded } from 'vue-router'
import api from '@/api' 
import MarkdownRenderer from '@/components/MarkdownRenderer.vue' // Vorschau-Komponente für Markdown
import { useUserStore } from '@/stores/useUserStore'

const errors = ref({})            
const router = useRouter()          
const tagList = ref<string[]>([])   
const route = useRoute() as RouteLocationNormalizedLoaded
const isArticleCreate = route.name === 'ArticleCreate' 
const store = useUserStore()        // Aktuelle User-Daten, insbesondere Token
const formStore = ref({
  title: '',
  description: '',
  body: '',
  tagList: '',
})

//Liste der Bild-URLs, die zum Artikel gehören
const uploadedImages = ref<string[]>([])
async function getArticle() {
  const { article } = await api.getArticle(route.params.id as string)

  tagList.value = article.tagList
  formStore.value.body = article.body
  formStore.value.description = article.description
  formStore.value.title = article.title

  uploadedImages.value = (article as any).imageUrls ?? [] // Bild-URLs vom Server übernehmen
}

// --------------------  BILD HOCHLADEN UND MARKDOWN ERGÄNZEN ------------------------
async function uploadImage(event: Event) {
  const files = (event.target as HTMLInputElement).files
  if (!files || files.length === 0) return

  const formData = new FormData()
  formData.append('file', files[0])  // Muss exakt zum Backend passen

  const slug = route.params.id
  const response = await fetch(`/api/articles/${slug}/images`, {
    method: 'POST',
    body: formData,
    headers: {
      Authorization: `Token ${store.userInfo?.token}`, // Authentifizierung mit Token
    },
  })

  const json = await response.json()
  const imageUrl = json.uploaded // Backend liefert Bild-URL unter "uploaded"

  if (response.ok && imageUrl) {
    uploadedImages.value.push(imageUrl) // URL zur Vorschau hinzufügen
    formStore.value.body += `\n\n![alt text](${imageUrl} "Image")\n\n` // Direkt ins Markdown einfügen
  } else {
    console.error('Image upload failed or missing imageUrl in response.', json)
  }
}
// Kopiert fertigen Markdown-Link in Zwischenablage
function copyMarkdown(url: string) {
  navigator.clipboard.writeText(`![alt text](${url} "Title")`)
  // ------------------------------------------------------------------------------------------------------------------------
}
function createArticle() {
  return api.createArticle({
    article: Object.assign({}, formStore.value, { tagList: tagList.value }),
  })
}
function updateArticle() {
  return api.updateArticle({
    article: Object.assign({}, formStore.value, { tagList: tagList.value }),
    slug: route.params.id as string,
  })
}
function onEnter() {
  if (!formStore.value.tagList || tagList.value.includes(formStore.value.tagList)) return
  tagList.value.push(formStore.value.tagList)
  formStore.value.tagList = ''
}
const { isLoading, execute: onSubmit } = useAsyncState(
  async () => {
    return (isArticleCreate ? createArticle() : updateArticle())
      .then(({ article }) => {
        router.push(`/article/${article.slug}`)
      })
      .catch((error) => {
        errors.value = error.errors || {} 
      })
  },
  null,
  { immediate: false },
)

onMounted(() => {
  if (!isArticleCreate) getArticle()
})
</script>

<template>
  <div class="editor-page">
    <div class="container page">
      <div class="row">
        <div class="col-md-10 offset-md-1 col-xs-12">
          <error-messages :errors="errors" />
          <form autocomplete="on" @submit.prevent="() => onSubmit()">
            <fieldset>
              <fieldset class="form-group">
                <input
                  v-model="formStore.title"
                  required
                  type="text"
                  name="title"
                  placeholder="Article Title"
                  class="form-control form-control-lg"
                >
              </fieldset>
              <fieldset class="form-group">
                <input
                  v-model="formStore.description"
                  required
                  type="text"
                  name="description"
                  class="form-control"
                  placeholder="What's this article about?"
                >
              </fieldset>
              <fieldset class="form-group">
                <label>Write your article (Markdown supported)</label>
                <textarea
                  v-model="formStore.body"
                  rows="8"
                  required
                  name="body"
                  class="form-control"
                  placeholder="Write your article (in markdown)"
                />
              </fieldset>

              <!--  Live-Vorschau des Markdown-Texts -->
              <fieldset class="form-group">
                <label>Live Preview</label>
                <div class="border rounded p-3" style="background-color: #f9f9f9;">
                  <MarkdownRenderer :source="formStore.body" />
                </div>
              </fieldset>

              <!--  Bild-Upload-Feld -->
              <fieldset class="form-group">
                <label>Upload image for this article</label>
                <input
                  type="file"
                  accept="image/*"
                  @change="uploadImage"
                  class="form-control"
                />
              </fieldset>

              <!--  Liste der hochgeladenen Bilder mit Copy-Button -->
              <div v-if="uploadedImages.length > 0" class="form-group">
                <label>Available image URLs:</label>
                <ul>
                  <li
                    v-for="url in uploadedImages"
                    :key="url"
                    style="margin-bottom: 0.5rem"
                  >
                    <code>{{ `![alt text](${url} "Title")` }}</code>
                    <button
                      class="btn btn-sm btn-outline-secondary"
                      @click="() => copyMarkdown(url)"
                    >
                      Copy Markdown
                    </button>
                  </li>
                </ul>
              </div>
              <fieldset class="form-group">
                <input
                  v-model="formStore.tagList"
                  type="text"
                  name="tagList"
                  class="form-control"
                  placeholder="Enter tags"
                  @keydown.enter.prevent="onEnter"
                >
                <div class="tag-list">
                  <span
                    v-for="(tag, index) in tagList"
                    :key="tag"
                    class="tag-default tag-pill"
                  >
                    <i class="ion-close-round" @click="tagList.splice(index, 1)" />
                    {{ tag }}
                  </span>
                </div>
              </fieldset>
              <button
                type="submit"
                :disabled="isLoading"
                class="btn btn-lg pull-xs-right btn-primary"
              >
                Publish Article
              </button>

            </fieldset>
          </form>
        </div>
      </div>
    </div>
  </div>
</template>
