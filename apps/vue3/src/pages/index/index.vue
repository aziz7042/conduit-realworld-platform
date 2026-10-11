<script lang="ts" setup>
import PopularTags from './components/PopularTags.vue'
import SearchField from '@/pages/index/components/SearchField.vue'
import { useUserStore } from '@/stores/useUserStore'
import type { ArticleListProps, ArticleToggleOptions } from '@/types'

const store = useUserStore()
const getOptionsForLabel: Record<string, { author?: string; tag?: string; query?: string }> = {
  'Global Feed': {},
  'Your Feed': { author: store.userInfo?.username }
}
const activeLabel = ref(store.isLoggedIn ? 'Your Feed' : 'Global Feed')
const articleListProps = ref<ArticleListProps>(getOptionsForLabel[activeLabel.value])
const articleToggleOptions = ref<ArticleToggleOptions[]>([
  {
    label: 'Your Feed',
    show: store.isLoggedIn,
  },
  { label: 'Global Feed' },
])
function handleTabClick() {
  if (['Your Feed', 'Global Feed'].includes(activeLabel.value)) {
    if (articleToggleOptions.value.length === 3) {
      articleToggleOptions.value.pop()
    }

    articleListProps.value = getOptionsForLabel[activeLabel.value]
  }
}
function handleTagClick(tag: string) {
  if (articleToggleOptions.value.length === 3) {
    articleToggleOptions.value.pop()
  }
  activeLabel.value = tag
  articleListProps.value = { tag }
  if (articleToggleOptions.value.length === 2) {
    articleToggleOptions.value.push({
      label: tag,
      icon: 1,
    })
  } else {
    articleToggleOptions.value[2].label = tag
  }
}

function handleSearchClick(query: string) {
  if (articleToggleOptions.value.length === 3) {
    articleToggleOptions.value.pop()
  }
  activeLabel.value = query
  articleListProps.value = { query }
  if (articleToggleOptions.value.length === 2) {
    articleToggleOptions.value.push({
      label: query,
      icon: 2,
    })
  } else {
    articleToggleOptions.value[2].label = query
  }
}

</script>

<template>
  <div class="home-page">
    <div v-if="!store.isLoggedIn" class="banner">
      <div class="container">
        <h1 class="logo-font">
          conduit
        </h1>
        <p>A place to share your knowledge.</p>
      </div>
    </div>

    <div class="container page">
      <div class="row">
        <div class="col-md-9">
          <article-toggle v-model="activeLabel" :options="articleToggleOptions" @change="handleTabClick" />
          <article-list :remote-params="articleListProps" />
        </div>

        <div class="col-md-3">
          <div v-if="store.isLoggedIn" class="box">
              <SearchField @search="handleSearchClick" />
              <br><br><br>
          </div>
          <div>
            <PopularTags @change="handleTagClick" />
          </div>
        </div>
      </div>
    </div>
  </div>
</template>
