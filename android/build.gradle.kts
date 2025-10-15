allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: org.gradle.api.file.Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: org.gradle.api.file.Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}

subprojects {
    project.evaluationDependsOn(":app")

    // Force Java 17 compatibility and suppress obsolete warnings across all modules.
    // This is the final override to fix the 'source value 8 is obsolete' warnings
    tasks.withType<org.gradle.api.tasks.compile.JavaCompile>().configureEach {
        sourceCompatibility = "17"
        targetCompatibility = "17"
        // This argument directly suppresses the exact warning the console suggests.
        options.compilerArgs.add("-Xlint:-options")
    }
}

tasks.register<org.gradle.api.tasks.Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
