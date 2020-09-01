package com.softwareag.scriptpack;

import java.io.BufferedReader;
import java.io.IOException;

@FunctionalInterface
public interface BufferedReaderSupplier {

    BufferedReader get() throws IOException;
}
