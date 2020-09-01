package com.softwareag.scriptpack;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.StandardOpenOption;
import java.util.Locale;

public class ScriptPackGenerator {

    private static final String PAYLOAD_EXTRACT_WIN_RESOURCE = "payload-extract-code.bat";

    private static final String PAYLOAD_EXTRACT_POSIX_RESOURCE = "payload-extract-code.sh";

    private static final String PAYLOAD_EXTRACT_MARK_WIN = "REM PAYLOAD-EXTRACT-CODE";

    private static final String PAYLOAD_EXTRACT_MARK_POSIX = "# PAYLOAD-EXTRACT-CODE";

    private static final int READ_BUF_SIZE = 1024;

    private final Path inputScript;

    private final Path inputArchive;

    private final Path output;

    private final boolean windows;

    public ScriptPackGenerator(Path inputScript, Path inputArchive, Path output) {
        this(inputScript, inputArchive, output, System.getProperty("os.name").toLowerCase(Locale.ENGLISH).contains("windows"));
    }

    public ScriptPackGenerator(Path inputScript, Path inputArchive, Path output, boolean windows) {
        this.inputScript = inputScript;
        this.inputArchive = inputArchive;
        this.output = output;
        this.windows = windows;
    }

    public void generate() throws Exception {
        StringBuilder script = read(() -> getUserResource(inputScript));
        insertPayloadExtractCode(script);
        Files.write(output, script.toString().getBytes(StandardCharsets.UTF_8));
        appendPayload();
    }

    private BufferedReader getUserResource(Path path) throws IOException {
        return Files.newBufferedReader(inputScript, StandardCharsets.UTF_8);
    }

    private BufferedReader getLocalResource(String resource) {
        return new BufferedReader(new InputStreamReader(getClass().getClassLoader().getResourceAsStream(resource), StandardCharsets.UTF_8));
    }

    private StringBuilder read(BufferedReaderSupplier src) throws IOException {
        try (BufferedReader reader = src.get()) {
            char[] buf = new char[READ_BUF_SIZE];
            int bytesRead = 0;
            StringBuilder content = new StringBuilder();
            while (-1 != (bytesRead = reader.read(buf))) {
                content.append(buf, 0, bytesRead);
            }
            return content;
        }
    }

    private void insertPayloadExtractCode(StringBuilder script) throws IOException {
        String payloadExtractMark = windows ? PAYLOAD_EXTRACT_MARK_WIN : PAYLOAD_EXTRACT_MARK_POSIX;
        int start = script.indexOf(payloadExtractMark);
        if (start < 0) {
            throw new IOException(payloadExtractMark + " not found in inputScript!");
        }
        int end = start + payloadExtractMark.length();
        String payloadExtractResource = windows ? PAYLOAD_EXTRACT_WIN_RESOURCE : PAYLOAD_EXTRACT_POSIX_RESOURCE;
        String replacement = read(() -> getLocalResource(payloadExtractResource)).toString();
        script.replace(start, end, replacement);
    }

    private void appendPayload() throws IOException {
        try (OutputStream writer = Files.newOutputStream(output, StandardOpenOption.WRITE, StandardOpenOption.APPEND);
                        InputStream reader = Files.newInputStream(inputArchive)) {
            byte[] buf = new byte[READ_BUF_SIZE];
            int bytesRead = 0;
            while (-1 != (bytesRead = reader.read(buf))) {
                writer.write(buf, 0, bytesRead);
            }
        }
    }
}
