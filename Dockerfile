FROM ruby:3.2.4

# Dependências do sistema
RUN apt-get update -qq && apt-get install -y \
  build-essential \
  libpq-dev \
  curl \
  git \
  vim \
  && rm -rf /var/lib/apt/lists/*

# Node.js 20 LTS via NodeSource
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
  && apt-get install -y nodejs \
  && rm -rf /var/lib/apt/lists/*

# Yarn via npm
RUN npm install -g yarn

WORKDIR /app

# Gems
COPY Gemfile Gemfile.lock ./
RUN bundle install

# Código
COPY . .

EXPOSE 3000
COPY entrypoint.sh /app/entrypoint.sh
RUN chmod +x /app/entrypoint.sh
CMD ["/app/entrypoint.sh"]