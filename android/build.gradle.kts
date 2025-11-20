
import com.android.build.gradle.BaseExtension
extra.apply {
    set("compileSdkVersion", 36)
    set("minSdkVersion", 21)
    set("targetSdkVersion", 36)
    // set("kotlin_version", "1.9.22") 
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
        afterEvaluate {
      project.extensions.findByType(BaseExtension::class.java)?.apply { compileSdkVersion(36) }
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