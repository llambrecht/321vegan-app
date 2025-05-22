- [🌱 Introduction](#-introduction)
  - [Many thanks to you all!](#many-thanks-to-you-all)
  - [Why read our guidelines?](#why-read-our-guidelines)
  - [The types of contribution we are looking for](#the-types-of-contribution-we-are-looking-for)
  - [The types of contribution we are NOT looking for](#the-types-of-contribution-we-are-not-looking-for)
- [🚦 Basic Rules](#-basic-rules)
  - [Our expectations in terms of behaviour](#our-expectations-in-terms-of-behaviour)
  - [Issues tracker](#issues-tracker)
  - [Bug reports](#bugs-reports)
  - [Feature Requests](#feature-requests)
  - [Pull Requests](#pull-requests)
    - [For your first contribution](#for-your-first-contribution)
    - [For members of the 321Vegan team of contributors](#for-members-of-the-321vegan-team-of-contributors)
    - [Commit Messages Convention](#commit-messages-convention)
- [🛠️ Setting Up the Project](#️-setting-up-the-project)
  - [🔨 Prerequisites](#-prerequisites)
  - [👣 Step-by-Step Setup](#-step-by-step-setup)
  - [🪲 Troubleshooting Tips](#-troubleshooting-tips)
- [🌍 Community](#community)
- [💚 Support this project!](#support-this-project)
- [📜 Code of Conduct](#code-of-conduct)

# 🌱 Introduction

## Many thanks to you all!

> First of all, thank you for considering contributing to 321Vegan and helping make veganism easy for everyone. It's people like you who make 321Vegan such a great tool.
> No contribution is too small—whether it's fixing a typo, improving documentation, reporting bugs, or submitting a feature, every bit counts.
> We’re here to help, we all started somewhere, so don’t hesitate to ask questions, seek guidance, or learn along the way. Your perspective matters, and your contribution is valued.

### Why read our guidelines?

> Following these guidelines shows that you respect the time of the developers who manage and develop this open source project. In return, they will reciprocate by addressing your issue, evaluating changes and helping you finalise your pull requests.  
> As with the rest of the project, contributions to 321Vegan are governed by our [Code of Conduct](https://github.com/llambrecht/321vegan-app/blob/main/CODE_OF_CONDUCT.md).

### The types of contribution we are looking for:

> 321Vegan is an open source project and we welcome contributions from our community - you! There are many ways to contribute, from checking products for inclusion in our database, improving documentation, submitting bug reports and feature requests or writing code that can be incorporated into 321Vegan itself.

### The types of contribution we are NOT looking for:

> Please do not use the issue tracker tool for support questions. Check if other means such as our [Discord server](https://discord.com/invite/NV67QXS2JF) can help you solve your problem. Send a message on [Instagram](https://www.instagram.com/321vegan.app), or an email at [contact@321vegan.fr](mailto:contact@321vegan.fr?subject=Support) is also worth considering.

# Basic rules

## Our expectations in terms of behaviour:

> - Liability
> - Ensuring cross-platform compatibility for each change accepted. Windows, Mac, Debian and Ubuntu Linux.
> - Create issues for the major changes and improvements you want to make. Discuss things transparently and get feedback from the community.
> - Keep feature versions as small as possible, preferably one new feature per version.
> - Welcome newcomers and encourage new contributors from all walks of life. Visit the [321Vegan Community Code of Conduct](https://github.com/llambrecht/321vegan-app/blob/main/CODE_OF_CONDUCT.md).

## Issues tracker:

First and foremost: **Do NOT report security vulnerabilities in public issues!**  
Please disclose it responsibly by informing [the 321Vegan team](mailto:contact@321vegan.fr?subject=Security).  
We will assess the problem as soon as possible and give you an estimate of when we will have a patch and a version available for possible public release.

The issue tracker tool is the preferred method for [bug reports](#bugs),
[features requests](#features) and [pull requests](#pull-requests), but be sure to observe the following restrictions:

- Please **do NOT** use the issue tracker for personal assistance requests. Please contact [the 321Vegan team](mailto:contact@321vegan.fr?subject=Support).

- Please also **don't** go off topic or troll the issues. Keep the discussion on topic and make sure you respect other people's opinions.

## Bugs reports:

A bug is a _demontable_ problem caused by the directory code.
Good bug reports are extremely useful - please follow our guidelines here too!

Guidelines for bug reports:

1. **Use GitHub's issue finder** &mdash; check whether the problem has already been reported.

2. **Check if the problem has been solved** &mdash; try to reproduce it using the last `main` or `next` branch in the directory.

3. **Isolate the problem** &mdash; ideally create a reduced test case.

A good bug report shouldn't leave others needing to chase you for more information.
Please try to be as detailed as possible in your report.
What is your environment like? What steps will reproduce the problem? Which OS is experiencing the problem? What would you expect?  
All these details will help us to correct potential bugs.

Example:

> Short, descriptive bug report title
>
> A summary of the problem and the browser/operating system environment in which it occurs. If applicable, include the steps required to reproduce the bug.
>
> 1. This is the first step
> 2. This is the second step
> 3. Other stages, etc.
>
> `<url>` - a link to the reduced case test
>
> Any other information you would like to share about the problem you are reporting. Cela peut inclure les lignes de code que vous avez identifiées comme à l'origine du bug, et des solutions potentielles (et vos opinions sur leur mérite).

## Feature Requests:

Feature requests are welcome. But please take a moment to consider whether your idea matches the scope and objectives of the project.  
It's up to _you_ to convince the project developers of the merits of this feature.
Please provide as much detail and context as possible.

## Pull Requests:

Pull requests - patches, improvements, new features - are a fantastic help. However, they must remain concentrated in their scope and avoid containing unrelated commits. Please ask first before embarking on a major pull request (e.g. feature implementation, code refactoring), otherwise you risk spending a lot of time working on something that the project developers may not want to merge into the project.

### For your first contribution:

> Not sure where to start contributing to 321Vegan? You can start by examining these problems for beginners and requests for help:
> Beginner problems - problems that should only require a few lines of code and a test or two.
> Help-seeking problems - problems that should be a little more complex than beginner problems.
> The two lists of issues are sorted by total number of comments. While not perfect, the number of comments is a reasonable approximation of the impact a given change will have.

> If you've never created a pull request before, welcome :smile: You can learn how with this series of _free_ tutorials, [How to Contribute to an Open Source Project on GitHub](https://egghead.io/courses/how-to-contribute-to-an-open-source-project-on-github).

1. [Fork](https://docs.github.com/en/pull-requests/collaborating-with-pull-requests/working-with-forks/fork-a-repo) the project, clone your fork, and configure the remotes:

   ```bash
   # Clone your fork from the repo into the current directory
   git clone https://github.com/<your-username>/<repo-name>
   # Access the newly cloned directory
   cd <repo-name>
   # Assign the original repository to a remote called «upstream»
   git remote add upstream https://github.com/llambrecht/321vegan-app/<repo-name>
   ```

2. If you cloned some time ago, retrieve the latest changes from the main:

   ```bash
   git checkout main
   git pull upstream main
   ```

3. Create a new topic branch (outside the main project development branch) to contain, modify or correct your functionality:

   ```bash
   git checkout -b <topic-branch-name>
   ```

4. Be sure to update or add to the tests as necessary. Patches and features will not be accepted without testing.

5. If you have added or modified a feature, make sure you document it accordingly in the `README.md` file.

6. Push your branch into your fork:

   ```bash
   git push origin <topic-branch-name>
   ```

7. [Open a Pull Request](https://docs.github.com/fr/pull-requests/collaborating-with-pull-requests/proposing-changes-to-your-work-with-pull-requests/about-pull-requests) with a clear title and description.

> Now you're ready to make your changes! Don't hesitate to ask for help: everyone is a beginner at this stage :smile_cat:

> PS: if a manager asks you to "rebase" your PR, he or she tells you that a lot of code has changed and that you need to update your branch to make it easier to merge ;)

### For members of the 321Vegan team of contributors

1. Clone the repository and create a branch

   ```bash
   git clone https://github.com/llambrecht/321vegan-app.git
   cd <repo-name>
   git checkout -b <topic-branch-name>
   ```

2. Be sure to update or add to the tests as necessary. Patches and features will not be accepted without testing.

3. If you have added or modified a feature, make sure you document it accordingly in the `README.md` file.

4. Push your branch into our repo

   ```bash
   git push origin <topic-branch-name>
   ```

5. Open a Pull Request using your branch with a clear title and description.

Optionally, you can help us with this procedure. But don't worry if it's too complicated, we can help you and teach you as you go along. :)

#### Commit Messages Convention:

- Commit test files prefixed with `test: ...` ou `test(scope): ...`
- Commit bug fixes prefixed with `fix: ...` or `fix(scope): ...`
- Commit new features prefixed with `feat: ...` or `feat(scope): ...`
- Commit changes in `package.json`, `.gitignore` and other meta files prefixed with `chore(filename without ext): ...`
- Commit modifications to README files or comments prefixed with `docs: filename without ext`
- Commit style changes prefixed with `style: standard`

---

## Setting Up the Project

Before you start contributing code, you’ll want to get the project running locally on your machine. Here’s how to set up the `321Vegan` Flutter app and launch it inside an emulator:

### 🔨 Prerequisites

Make sure you have the following installed:

- [Flutter SDK](https://flutter.dev/docs/get-started/install)
- [Android Studio](https://developer.android.com/studio) or [Visual Studio Code](https://code.visualstudio.com/)
- An Android or iOS emulator (or a physical device)

> 💡 If you're new to Flutter, check out the official [Flutter Getting Started Guide](https://flutter.dev/docs/get-started/install) for setup instructions specific to your OS.

---

### 👣 Step-by-Step Setup

1. **Clone the repository**

   ```bash
   git clone https://github.com/llambrecht/321vegan-app.git
   cd 321vegan-app
   ```

2. **Set up the sample database and Google service keys**

   Copy and rename the following files by removing the word `sample` from their filenames:

   ```
   flutter_app/android/app/google-services-sample.json
   flutter_app/ios/GoogleService-Info-sample.plist
   flutter_app/lib/assets/cosmetics_sample.db.gz
   flutter_app/lib/assets/vegan_products_sample.db.gz
   ```

   - Rename `google-services-sample.json` to `google-services.json`
   - Rename `GoogleService-Info-sample.plist` to `GoogleService-Info.plist`
   - Rename `cosmetics_sample.db.gz` to `cosmetics.db.gz`
   - Rename `vegan_products_sample.db.gz` to `vegan_products.db.gz`

   > These files are required for authentication and to provide the sample databases used by the app

3. **Get the Flutter packages**

   This pulls in all the dependencies needed to run the app:

   ```bash
   flutter pub get
   ```

4. **Set up an emulator (if needed)**

   If you don’t already have an emulator:

   - Open **Android Studio**
   - Go to **Device Manager** → **Create Virtual Device**
   - Choose a phone model and system image, then click **Finish**
   - Start the emulator

5. **Run the app**

   Once the emulator is running (or a physical device is connected), launch the app:

   ```bash
   flutter run
   ```

   > 🧪 Tip: You can also use `flutter run -d <device_id>` if you have multiple devices/emulators.

   Our team uses Visual Studio Code, so if you decide to go with that too, it'll be easier for us to help you out. If you prefer a different editor, that’s totally fine — we’ll still do our best to support you!

6. **You're up and running! 🎉**
   If you are stuck at any step in the process, don't hesitate to contact us

---

### 🪲 Troubleshooting Tips

- **Use Flutter Doctor**

  Run this command to check if everything is set up correctly:

  ```bash
  flutter doctor
  ```

- If you see missing dependencies, follow the instructions provided by `flutter doctor` to fix them.

- If you run into issues, don't hesitate to ask for help

**IMPORTANT**: By submitting a patch, you agree to license your work under the same licence as that used by the project.

# Community

The main project team can be found in the [Team](https://github.com/llambrecht/321vegan-app/blob/main/TEAM.md).

# Support this project!

This project is run by volunteers. You can support this project by making a donation:
🫛 [Buy me a tofu](https://buymeacoffee.com/321vegan)
Your help is invaluable, thank you from the bottom of our heart 💚!

# Code of conduct

All persons interacting in the 321Vegan project code bases, issue trackers, discussions and mailing lists are requested to follow the [321Vegan Community Code of Conduct](https://github.com/llambrecht/321vegan-app/blob/main/CODE_OF_CONDUCT.md).
