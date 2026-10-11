<script lang="ts" setup>
import { useAsyncState } from '@vueuse/core'
import api from '@/api'
import type { UserInfo } from '@/types'
import { useUserStore } from '@/stores/useUserStore'

const router = useRouter()
const store = useUserStore()
const fromStoreUser = ref<UserInfo>({
  image: '',
  username: '',
  bio: '',
  email: '',
  //password: '',
})

const fromStorePW = ref<UserInfo>({
  image: '',
  username: '',
  bio: '',
  email: '',
  newPassword: '',
  oldPassword: '',
})

// Eine neue Variable, die die ausgewählte Datei speichert
const selectedFile = ref<File | null>(null)


// Diese Methode wird aufgerufen, wenn der Benutzer eine Datei auswählt
// Die ausgewählte Datei wird gespeichert und eine lokale Vorschau wird im Profilbild-Feld angezeigt
function onFileChange(event: Event) {
  
  // Das Ziel des Events (also das Dateiupload-Inputfeld) wird aus dem Event herausgelesen
  const target = event.target as HTMLInputElement

  // Es wird geprüft, ob überhaupt Dateien im Inputfeld vorhanden sind und ob mindestens eine Datei ausgewählt wurde
  if (target.files && target.files.length > 0) {
    selectedFile.value = target.files[0]   // Die ausgewählte Datei wird in der Variable selectedFile gespeichert, um sie später hochladen zu können
    
    // Zusätzlich wird im Profil-Formular direkt eine lokale Vorschau des Bildes angezeigt
    // Dazu wird eine temporäre URL für die ausgewählte Datei erstellt und im Profilbild-Feld gesetzt
    fromStoreUser.value.image = URL.createObjectURL(selectedFile.value)
  }
}


const { isLoading, execute: onSubmit } = useAsyncState(
  async () => {

    // Vor dem Senden der Formulardaten wird geprüft, ob der Benutzer ein neues Profilbild ausgewählt hat
    if (selectedFile.value) {
      const formData = new FormData() // Ein neues FormData-Objekt wird erstellt, um die Datei zu versenden
      formData.append('file', selectedFile.value) // Die ausgewählte Datei wird angehängt
      
      // Die Datei wird per POST-Anfrage an den Server gesendet
      await fetch('http://localhost:8081/api/profiles/image', {
        method: 'POST',
        headers: {
          Authorization: `Bearer ${store.userInfo?.token}`, // Das Authentifizierungstoken wird mitgesendet
        },
        body: formData, // und die Datei wird im Body der Anfrage mitgeschickt
      })
        .then(async (res) => {
          const data = await res.json() // Die Antwort vom Server wird verarbeitet
          fromStoreUser.value.image = data.imageUrl // und die vom Server zurückgegebene Bild-URL wird im Benutzerprofil gespeichert
        })
        .catch((err) => {
          console.error('Bild-Upload fehlgeschlagen', err) // Falls ein Fehler auftritt, wird dieser in der Konsole ausgegeben
        })
    }

    return await api.updateUser({ user: fromStoreUser.value }).then(({ user }) => {
      store.userInfo = user
      router.push(`/profile/${user.username}`)
    })
  },
  null,
  { immediate: false },
)

const { isLoading: isLoadingPW, execute: onSubmitPassword } = useAsyncState(
    async () => {
      return await api.updateUser({ user: fromStorePW.value }).then(({ user }) => {
        store.userInfo = user
        router.push(`/profile/${user.username}`)
      })
    },
    null,
    { immediate: false },
)

function onLogout() {
  store.userInfo = null
  localStorage.removeItem('jwt-token')
  router.push('/')
}

onMounted(() => {
  if (store.userInfo) {
    fromStoreUser.value = { ...fromStoreUser.value, ...store.userInfo }
    fromStorePW.value = { ...fromStorePW.value, ...store.userInfo }
  }
})
</script>

<template>
  <div class="settings-page">
    <div class="container page">
      <div class="row">
        <div class="col-md-6 offset-md-3 col-xs-12">
          <h1 class="text-xs-center">
            Your Settings
          </h1>
          <form autocomplete="on" @submit.prevent="() => onSubmit()">
            <fieldset>

              <fieldset class="form-group">

                <!-- Neues Dateiupload-Feld, um ein Profilbild auszuwählen -->
                <label for="file">Profilbild auswählen:</label>
                <input type="file" id="file" accept="image/*" @change="onFileChange" class="form-control" />
              </fieldset>
              
              <fieldset class="form-group">

                <!-- Anzeige des Dateinamens der aktuell ausgewählten Datei -->
                <label v-if="selectedFile">Ausgewählte Datei: {{ selectedFile.name }}</label>
              </fieldset>


              <fieldset class="form-group">

                <!-- Vorschau des Profilbildes, das der Benutzer ausgewählt hat -->
                <img v-if="fromStoreUser.image" :src="fromStoreUser.image" class="img-preview" style="max-width: 100px; border-radius: 5px;" />

                
              </fieldset>
              <fieldset class="form-group">
                <input
                    v-model="fromStoreUser.username" type="text" placeholder="Your Name"
                    class="form-control form-control-lg" id="name"
                >
              </fieldset>
              <fieldset class="form-group">
                <textarea
                    v-model="fromStoreUser.bio" rows="8" placeholder="Short bio about you"
                    class="form-control form-control-lg" id="bio"
                />
              </fieldset>
              <fieldset class="form-group">
                <input v-model="fromStoreUser.email" type="text" placeholder="Email" class="form-control form-control-lg" id="mail">
              </fieldset>
              <button class="btn btn-lg btn-primary pull-xs-right" :disabled="isLoading">
                Update Settings
              </button>
            </fieldset>
          </form>
          <hr>
          <form autocomplete="on" @submit.prevent="() => onSubmitPassword()">
            <fieldset>
              <fieldset class="form-group">
                <input
                    v-model="fromStorePW.oldPassword" type="password" placeholder="Old Password"
                    class="form-control form-control-lg" id="opw"
                >
              </fieldset>
              <fieldset class="form-group">
                <input
                    v-model="fromStorePW.newPassword" type="password" placeholder="New Password"
                    class="form-control form-control-lg" id="npw"
                >
              </fieldset>
              <button class="btn btn-lg btn-primary pull-xs-right" :disabled="isLoadingPW">
                Update Password
              </button>
            </fieldset>
          </form>
          <hr>
          <button class="btn btn-outline-danger" @click="onLogout">
            Or click here to logout.
          </button>
        </div>
      </div>
    </div>
  </div>
</template>
