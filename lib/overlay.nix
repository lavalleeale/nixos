{ inputs, system }:

final: prev: {
  gorg = inputs.gorg-flake.packages.${system}.default;
  wl-paste = inputs.wl-paste-flake.packages.${system}.default;
  zen-browser = inputs.zen-browser-flake.packages.${system}.default;
  zen-browser-vaapi =
    final.runCommand "${final.zen-browser.name}-vaapi"
      {
        nativeBuildInputs = [ final.makeWrapper ];
        meta = final.zen-browser.meta;
        passthru = final.zen-browser.passthru;
      }
      ''
        cp -a ${final.zen-browser} "$out"
        chmod -R u+w "$out"
        substituteInPlace "$out/bin/zen-beta" \
          --replace-fail '${final.zen-browser}' "$out"
        cat >> "$out"/lib/zen-bin-*/mozilla.cfg <<'EOF'

        // Prefer VA-API hardware video decoding on the AMD laptop.
        defaultPref("media.ffmpeg.vaapi.enabled", true);
        defaultPref("media.hardware-video-decoding.force-enabled", true);
        defaultPref("media.rdd-ffmpeg.enabled", true);
        EOF
        mv "$out/bin/zen-beta" "$out/bin/zen-beta-unwrapped"
        makeWrapper "$out/bin/zen-beta-unwrapped" "$out/bin/zen-beta" \
          --set-default MOZ_ENABLE_WAYLAND 1 \
          --set LIBVA_DRIVER_NAME radeonsi \
          --set VDPAU_DRIVER radeonsi \
          --set MOZ_DISABLE_RDD_SANDBOX 1
      '';
}
