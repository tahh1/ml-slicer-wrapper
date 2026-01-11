FROM python:3.8-bullseye

# ----------------------------
# System dependencies
# ----------------------------
RUN apt-get update && apt-get install -y \
    curl \
    wget \
    gnupg \
    lsb-release \
    build-essential \
    ca-certificates \
    git \
    && rm -rf /var/lib/apt/lists/*

# ----------------------------
# Node.js 16.x + npm 8.x
# ----------------------------
RUN curl -fsSL https://deb.nodesource.com/setup_16.x | bash - \
    && apt-get install -y nodejs \
    && npm install -g npm@8.19.4

# ----------------------------
# Soufflé (official PPA)
# ----------------------------
RUN wget https://souffle-lang.github.io/ppa/souffle-key.public \
    -O /usr/share/keyrings/souffle-archive-keyring.gpg \
    && echo "deb [signed-by=/usr/share/keyrings/souffle-archive-keyring.gpg] \
    https://souffle-lang.github.io/ppa/ubuntu/ stable main" \
    > /etc/apt/sources.list.d/souffle.list \
    && apt-get update \
    && apt-get install -y souffle \
    && rm -rf /var/lib/apt/lists/*

# ----------------------------
# Python dependencies (excluding ml-slicer)
# ----------------------------
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# ----------------------------
# Clone ml-slicer and init submodules
# ----------------------------
RUN git clone https://github.com/tahh1/ml-slicer.git /app/ml-slicer \
    && cd /app/ml-slicer \
    && git submodule update --init --recursive

# ----------------------------
# Build Pyright (EXACT manual steps)
# ----------------------------
RUN cd /app/ml-slicer/src/mlslicer/tools/pyright \
    && npm install \
    && cd packages/pyright \
    && npm run build

# ----------------------------
# Install ml-slicer (Python)
# ----------------------------
RUN cd /app/ml-slicer \
    && pip install -e .

# ----------------------------
# Copy FastAPI application
# ----------------------------
COPY app /app/app

# ----------------------------
# Expose API port
# ----------------------------
EXPOSE 8000

# ----------------------------
# Run FastAPI server
# ----------------------------
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
