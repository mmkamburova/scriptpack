package com.softwareag.scriptpack.plugin;

import org.gradle.api.Plugin;
import org.gradle.api.Project;

public class ScriptPackPlugin implements Plugin<Project> {

    @Override
    public void apply(Project project) {
        project.getTasks().register("generateScriptPack", GenerateScriptPackTask.class);
    }
}
