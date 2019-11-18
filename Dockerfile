FROM blakedickie/arch-base:latest

RUN pacman --sync --noconfirm powerdns postgresql-libs setconf

WORKDIR /powerdns

COPY dns-launch.sh dns-launch.sh
RUN chmod 755 "dns-launch.sh"

EXPOSE 80/tcp
EXPOSE 53/tcp
EXPOSE 53/udp

CMD "./dns-launch.sh"
