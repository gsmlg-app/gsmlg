plugins { id("com.android.asset-pack") }

assetPack {
    packName.set("conversation_title")
    dynamicDelivery { deliveryType.set("install-time") }
}

// Asset packs use src/main/assets. These generated weights stay out of Git.
val verifyTitleModel by tasks.registering(Exec::class) {
    workingDir(rootProject.projectDir.parentFile)
    commandLine("python3", "tools/conversation_title/prepare.py")
}
val prepareTitleModelAssets by tasks.registering(Copy::class) {
    dependsOn(verifyTitleModel)
    from(rootProject.file("../assets/models/conversation_title")) {
        include("*.gguf", "LICENSE", "NOTICE")
    }
    into(layout.projectDirectory.dir("src/main/assets/models/conversation_title"))
}
tasks.configureEach {
    if (name.startsWith("package") || name.startsWith("generate")) {
        dependsOn(prepareTitleModelAssets)
    }
}
