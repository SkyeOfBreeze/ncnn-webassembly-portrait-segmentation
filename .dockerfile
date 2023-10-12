# Point at any base image that you find suitable to extend.
FROM emscripten/emsdk:3.1.28

# Install required tools that are useful for your project i.e. ninja-build
WORKDIR /home
RUN apt update && apt install -y ninja-build wget git

# Create a directory for your source code
RUN mkdir ncnn-webassembly-portrait-segmentation
WORKDIR ncnn-webassembly-portrait-segmentation

# Copy your source code into the container
COPY . .

# Download and build your code
RUN wget https://github.com/Tencent/ncnn/releases/download/20230223/ncnn-20230223-webassembly.zip && unzip ncnn-20230223-webassembly.zip
RUN mkdir build && \
    cd build && \
    cmake -DCMAKE_TOOLCHAIN_FILE=$EMSDK/upstream/emscripten/cmake/Modules/Platform/Emscripten.cmake -DWASM_FEATURE=basic .. && \
    make -j4 && \
    cmake -DCMAKE_TOOLCHAIN_FILE=$EMSDK/upstream/emscripten/cmake/Modules/Platform/Emscripten.cmake -DWASM_FEATURE=simd .. && \
    make -j4 && \
    cmake -DCMAKE_TOOLCHAIN_FILE=$EMSDK/upstream/emscripten/cmake/Modules/Platform/Emscripten.cmake -DWASM_FEATURE=threads .. && \
    make -j4 && \
    cmake -DCMAKE_TOOLCHAIN_FILE=$EMSDK/upstream/emscripten/cmake/Modules/Platform/Emscripten.cmake -DWASM_FEATURE=simd-threads .. && \
    make -j4

# Copy the built files to a directory on the host system
# Replace /path/to/host/directory with the actual path on your host system where you want to store the built files
# -v $(pwd)/build:/out
RUN cp -r /home/ncnn-webassembly-portrait-segmentation/build /out
