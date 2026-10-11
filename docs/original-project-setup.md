# RealWorld mono Repository

RealWorld is a project with the goal of providing a unique sample application named Conduit defining a blog webpage similar to Medium.com for different programming languages and frameworks. Details on RealWorld can be found here https://main--realworld-docs.netlify.app/

## Development Environment

### Requirements

#### Mandatory

- git client (e.g., https://git-scm.com/downloads)
- .Net SDK 7.0 (https://dotnet.microsoft.com/en-us/download/dotnet/7.0)
- Node.js 21 (https://nodejs.org/en/download)
- Integrated Development Environments (IDEs) for C#/.Net7.0, vue3/TypeScript, and flutter/Dart (cf. Optional Requirements)

#### Optional

- JetBrains IDEs (Education Licenses are available using your @st.ovgu.de mailadress cf. https://www.jetbrains.com/lp/leaflets-gdc/students/)
- for .Net7.0/C# - JetBrains Rider (https://www.jetbrains.com/rider/)
- for vue3/TypeScript - JetBrains Webstorm (https://www.jetbrains.com/webstorm/)
- for Flutter/Dart - JetBrains IntelliJ Ultimate (https://www.jetbrains.com/idea/)
- for database inspection - JetBrains DataGrip (https://www.jetbrains.com/datagrip/)

### Setup

1. Checkout repository using git

```[bash]
git clone https://github.com/Chair-of-Software-Engineering-Magdeburg/realworld-mono.git realworld
```

2. This repository contains the following submodules

```
apps
|_ dotnet #Backend
|_ flutter #Frontend with flutter
|_ vue3 #Fronted with Vue.js
```

3. dotnet Backend (`apps/dotnet`)

- Open your preferred C#/.Net IDE (e.g., Rider) and import the dotnet using the `realworlddotnet.sln` project file
- After proper import you should be able to execute the backend excuting the API.csproj
- For configuration please refer to https://learn.microsoft.com/en-us/aspnet/core/fundamentals/environments?view=aspnetcore-7.0

4. Vue3 (`apps/vue3`)

- Open your preferred vue3/TypeScript IDE (e.g., Webstorm) and import the vue3 project
- Install Vue3 packages using (in Webstorm open an *.ts file and click on the Run 'npm install')

```[bash]
npm install
```

- Configure the project using the vite configuration (cf. https://vitejs.dev/config/)



- Execute realworld app using predefined scripts using in the `package.json` configuration (cf. https://docs.npmjs.com/cli/v10/using-npm/scripts)

5. flutter (`apps/flutter`)

- Open your preferred flutter/Dart IDE (e.g., IntelliJ) and import the flutter project
- Get flutter dependencies running (in Webstorm there usually occurs a notifcation or just refer to `pubspec.yaml` file)

```[bash]
flutter pub get
```
- build flutter for your target devive, for instance, for web 
```[bash]
flutter build web
flutter run -d chrome
``` 