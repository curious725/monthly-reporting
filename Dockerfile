FROM ruby:2.2.3

# Install PhantomJS
ENV PHANTOMJS_VERSION 2.1.1
ARG PHANTOMJS_FOLDER="phantomjs-$PHANTOMJS_VERSION-linux-x86_64"
RUN wget https://bitbucket.org/ariya/phantomjs/downloads/$PHANTOMJS_FOLDER.tar.bz2 \
&& tar xvjf $PHANTOMJS_FOLDER.tar.bz2 \
&& mv $PHANTOMJS_FOLDER/bin/phantomjs /usr/local/bin \
&& rm -rf $PHANTOMJS_FOLDER

RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

COPY Gemfile /usr/src/app/
COPY Gemfile.lock /usr/src/app/
RUN bundle install

COPY . /usr/src/app

EXPOSE 3000

CMD ["rails", "server", "-b", "0.0.0.0"]
