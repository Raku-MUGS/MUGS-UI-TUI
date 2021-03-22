ARG mugs_version=latest
FROM mugs-games:$mugs_version
ARG mugs_version

LABEL org.opencontainers.image.source=https://github.com/Raku-MUGS/MUGS-UI-TUI

USER root:root

RUN apt-get update \
 && apt-get -y --no-install-recommends install build-essential \
 && zef update \
 && zef install Term::termios \
 && apt-get purge -y --auto-remove build-essential \
 && rm -rf /var/lib/apt/lists/*

COPY . /home/raku

RUN zef install --deps-only . \
 && raku -c -Ilib bin/mugs-tui

RUN zef install . --/test

USER raku:raku

ENTRYPOINT ["mugs-tui"]
