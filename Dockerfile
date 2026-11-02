FROM debian:bookworm

ARG zapfast_VERSION
ARG BUILD_VERSION
ARG FULL_VERSION
ARG ARCH
ARG ZAPFAST_RELEASE

RUN mkdir -p /output/DEBIAN

# Upstream's .deb, extracted by build_debian.sh: usr/bin/zapfast, the .desktop
# file, the icon and the Omarchy theme hook in usr/share/zapfast. Upstream's
# licence copy moves to the Debian place (doc/zapfast/copyright, below), and
# no zapfast-portable.txt marker is shipped, so the built-in updater stays off.
COPY ${ZAPFAST_RELEASE}/usr /output/usr/
RUN rm -rf /output/usr/share/licenses
RUN mkdir -p /output/usr/share/doc/zapfast

COPY output/DEBIAN/control /output/DEBIAN/
COPY output/DEBIAN/postinst /output/DEBIAN/postinst
RUN chmod 755 /output/DEBIAN/postinst
COPY output/copyright /output/usr/share/doc/zapfast/
COPY output/changelog.Debian /output/usr/share/doc/zapfast/
COPY output/README.md /output/usr/share/doc/zapfast/
RUN chmod 644 /output/usr/share/doc/zapfast/*

RUN sed -i "s/FULL_VERSION/$FULL_VERSION/" /output/usr/share/doc/zapfast/changelog.Debian
RUN sed -i "s/zapfast_VERSION/$zapfast_VERSION/" /output/DEBIAN/control
RUN sed -i "s/BUILD_VERSION/$BUILD_VERSION/" /output/DEBIAN/control
RUN sed -i "s/SUPPORTED_ARCHITECTURES/$ARCH/" /output/DEBIAN/control

RUN dpkg-deb -Zxz --build /output /zapfast_${FULL_VERSION}.deb
