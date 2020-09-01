package com.softwareag.scriptpack.plugin;

import java.io.File;

import org.gradle.api.DefaultTask;
import org.gradle.api.logging.Logger;
import org.gradle.api.tasks.Input;
import org.gradle.api.tasks.InputFile;
import org.gradle.api.tasks.Optional;
import org.gradle.api.tasks.OutputFile;
import org.gradle.api.tasks.TaskAction;

import com.softwareag.scriptpack.ScriptPackGenerator;

public class GenerateScriptPackTask extends DefaultTask {

    private File inputScript = new File("inputscript.txt");

    private File inputArchive = new File("payload.zip");

    private Boolean windows = null;

    private File output = new File("scriptpack.txt");

    @InputFile
    public File getInputScript() {
        return inputScript;
    }

    public void setInputScript(File inputScript) {
        this.inputScript = inputScript;
    }

    @InputFile
    public File getInputArchive() {
        return inputArchive;
    }

    public void setInputArchive(File inputArchive) {
        this.inputArchive = inputArchive;
    }

    @Input
    @Optional
    public Boolean getWindows() {
        return windows;
    }

    public void setWindows(Boolean windows) {
        this.windows = windows;
    }

    @OutputFile
    public File getOutput() {
        return output;
    }

    public void setOutput(File output) {
        this.output = output;
    }

    @TaskAction
    public void generateScriptPack() throws Exception {
        Logger logger = getLogger();
        logger.lifecycle("Generating script pack...");
        ScriptPackGenerator generator = createScriptPackGenerator();
        generator.generate();
        logger.lifecycle("Done.");
    }

    private ScriptPackGenerator createScriptPackGenerator() {
        if (null != windows) {
            return new ScriptPackGenerator(inputScript.toPath(), inputArchive.toPath(), output.toPath(), windows.booleanValue());
        }
        return new ScriptPackGenerator(inputScript.toPath(), inputArchive.toPath(), output.toPath());
    }
}
