{
  inputs,
  config,
  ...
}: let
  # TRaSH custom formats scored into the general profiles. Scores come from the guide.
  sonarrCfs = {
    # Remux tiers left out: their 1900 beats tier-1 streaming WEB and would churn WEB-DLs into remuxes.
    hqGroups = [
      "d6819cba26b1a6508138d25fb5e32293" # HD Bluray Tier 01
      "c2216b7b8aa545dc1ce8388c618f8d57" # HD Bluray Tier 02
      "e6258996055b9fbab7e9cb2f75819294" # WEB Tier 01
      "58790d4e2fdcd9733aa7ae68ba2bb503" # WEB Tier 02
      "d84935abd3f8556dcd51d4f27e22d0a6" # WEB Tier 03
      "d0c516558625b04b363fa6c5c2c7cfd4" # WEB Scene
    ];
    repacks = [
      "ec8fa7296b64e8cd390a1600981f3923" # Repack/Proper
      "eb3d5cc0a2be0db205fb823640db6a3c" # Repack2
      "44e7c4de10ae50265753082e5dc76047" # Repack3
    ];
    streaming = [
      "d660701077794679fd59e8bdf4ce3a29" # AMZN
      "d9e511921c8cedc7282e291b0209cdc5" # ATV
      "f67c9ca88f463a48346062e8ad07713f" # ATVP
      "77a7b25585c18af08f60b1547bb9b4fb" # CC
      "36b72f59f4ea20aad9316f475f2d9fbb" # DCU
      "89358767a60cc28783cdc3d0be9388a4" # DSNP
      "7a235133c87f7da4c8cccceca7e3c7a6" # HBO
      "a880d6abc21e7c16884f3ae393f84179" # HMAX
      "f6cce30f1733d5c8194222a7507909bb" # HULU
      "0ac24a2a68a9700bcb7eeca8e5cd644c" # iT
      "81d1fbf600e2540cee87f3a23f9d3c1c" # MAX
      "d34870697c9db575f17700212167be23" # NF
      "1656adc6d7bb2c8cca6acfb6592db421" # PCOK
      "c67a75ae4a1715f2bb4d492755ba4195" # PMTP
      "6eb71887a8db6e783dd398446eb0e65d" # PLAY
      "da393fd4e2c0cce7c9dc2669c43e0593" # ROKU
      "ae58039e1319178e6be73caab5c42166" # SHO
      "1efe8da11bfd74fbbcd4d8117ddb9213" # STAN
      "9623c5c9cac8e939c1b9aedd32f640bf" # SYFY
      "bbcaf03147de0f73be2be4a9078dfa03" # 4OD
      "fcc09418f67ccaddcf3b641a22c5cfd7" # ALL4
      "dc503e2425126fa1d0a9ad6168c83b3f" # IP
      "fa5a16b951004c23e980d2913694a137" # ITVX
      "9f72dc1059a6b277c21cee6a1f15f13f" # MY5
      "b66a699fba6f9df91becab798d7502e5" # NOW
      "218e93e5702f44a68ad9e3c6ba87d2f0" # HD Streaming Boost
      "43b3cf48cb385cd3eac608ee6bca7f09" # UHD Streaming Boost
    ];
    unwanted = [
      "15a05bc7c1a36e2b57fd628f8977e2fc" # AV1
      "32b367365729d530ca1c124a0b180c64" # Bad Dual Groups
      "85c61753df5da1fb2aab6f2a47426b09" # BR-DISK
      "fbcb31d8dabd2a319072b84fc0b7249c" # Extras
      "9c11cd3f07101cdba90a2d81cf0e56b4" # LQ
      "e2315f990da2e2cbfc9fa5b7a6fcfe48" # LQ (Release Title)
      "e1a997ddb54e3ecbfe06341ad323c458" # Obfuscated
      "06d66ab109d4d2eddb2794d21526d140" # Retags
      "23297a736ca77c0fc8e70f8edd7ee56c" # Upscaled
      "ae575f95ab639ba5d15f663bf019e3e8" # Language: Not Original
    ];
  };

  # Audio formats left out: lossless audio scores (up to 5000) outweigh group tiers and drive size.
  # Streaming services left out: the guide scores them 0 for movies.
  radarrCfs = {
    hqGroups = [
      "4d74ac4c4db0b64bff6ce0cffef99bf0" # UHD Bluray Tier 01
      "a58f517a70193f8e578056642178419d" # UHD Bluray Tier 02
      "e71939fae578037e7aed3ee219bbe7c1" # UHD Bluray Tier 03
      "ed27ebfef2f323e964fb1f61391bcb35" # HD Bluray Tier 01
      "c20c8647f2746a1f4c4262b0fbbeeeae" # HD Bluray Tier 02
      "5608c71bcebba0a5e666223bae8c9227" # HD Bluray Tier 03
      "c20f169ef63c5f40c2def54abaf4438e" # WEB Tier 01
      "403816d65392c79236dcb6dd591aeda4" # WEB Tier 02
      "af94e0fe497124d1f9ce732069ec8c3b" # WEB Tier 03
    ];
    repacks = [
      "e7718d7a3ce595f289bfee26adc178f5" # Repack/Proper
      "ae43b294509409a6a13919dedd4764c4" # Repack2
      "5caaaa1c08c1742aa4342d8c4cc463f2" # Repack3
    ];
    hdr = [
      "493b6d1dbec3c3364c59d7607f7e3405" # HDR
      "923b6abef9b17f937fab56cfcf89e1f1" # DV (w/o HDR fallback)
    ];
    unwanted = [
      "b8cd450cbfa689c0259a01d9e29ba3d6" # 3D
      "cae4ca30163749b891686f95532519bd" # AV1
      "b6832f586342ef70d9c128d40c07b872" # Bad Dual Groups
      "cc444569854e9de0b084ab2b8b1532b2" # Black and White Editions
      "ed38b889b31be83fda192888e2286d83" # BR-DISK
      "0a3f082873eb454bde444150b70253cc" # Extras
      "e6886871085226c3da1830830146846c" # Generated Dynamic HDR
      "c465ccc73923871b3eb1802042331306" # Line/Mic Dubbed
      "90a6f9a284dff5103f6346090e6280c8" # LQ
      "e204b80c87be9497a8a6eaff48f72905" # LQ (Release Title)
      "7357cf5161efbf8c4d5d0c30b4815ee2" # Obfuscated
      "5c44f52a8714fdd79bb4d98e2673be1f" # Retags
      "712d74cd88bceb883ee32f773656b1f5" # Sing-Along Versions
      "bfd8eb01832d646a0a89c4deb46f8564" # Upscaled
    ];
  };

  # Existing profiles, managed by name. German DL and anime keep their manual setup.
  general = "HD (4k fallback)";
  any = "Any";
  movies = "4k (HD fallback)";
in {
  age.secrets.sonarrApiKey.file = "${inputs.self}/secrets/sonarrApiKey.age";
  age.secrets.radarrApiKey.file = "${inputs.self}/secrets/radarrApiKey.age";

  services.recyclarr = {
    enable = true;

    configuration.radarr.radarr = {
      base_url = "http://127.0.0.1:${toString config.services.radarr.settings.server.port}";
      api_key._secret = config.age.secrets.radarrApiKey.path;

      media_management.propers_and_repacks = "do_not_prefer";

      # File names only; folder format stays.
      media_naming.movie = {
        rename = true;
        standard = "standard";
      };

      # TRaSH "UHD Bluray + WEB" with a 1080p fallback. No remuxes or HDTV.
      quality_profiles = [
        {
          name = movies;
          reset_unmatched_scores.enabled = true;
          min_format_score = 0;
          upgrade = {
            allowed = true;
            until_quality = "Bluray-2160p";
            until_score = 10000;
          };
          # Remuxes disabled but ranked below 4K encodes: existing remux files get replaced by
          # 4K encodes, never by 1080p. Movies that should keep remuxes go on the remux profile.
          qualities = [
            {name = "Bluray-2160p";}
            {
              name = "WEB 2160p";
              qualities = ["WEBDL-2160p" "WEBRip-2160p"];
            }
            {
              name = "Remux-2160p";
              enabled = false;
            }
            {
              name = "Remux-1080p";
              enabled = false;
            }
            {name = "Bluray-1080p";}
            {
              name = "WEB 1080p";
              qualities = ["WEBDL-1080p" "WEBRip-1080p"];
            }
          ];
        }
        {
          # Guide-backed; assigned by hand to movies worth full quality. Guide default groups
          # (audio, HDR, streaming, unwanted, Golden Rule UHD) apply only to this profile.
          trash_id = "fd161a61e3ab826d3a22d53f935696dd"; # Remux + WEB 2160p
          reset_unmatched_scores.enabled = true;
        }
      ];

      custom_format_groups.add = [
        {
          trash_id = "7fc2751eef7e6bdc70b74136e5e35c76"; # [HDR Formats] DV (w/o HDR fallback)
        }
        {
          trash_id = "a3ac6af01d78e4f21fcb75f601ac96df"; # [Unwanted] Unwanted Formats
          select = [
            "7357cf5161efbf8c4d5d0c30b4815ee2" # Obfuscated
            "5c44f52a8714fdd79bb4d98e2673be1f" # Retags
          ];
        }
      ];

      custom_formats = [
        {
          trash_ids = radarrCfs.hqGroups ++ radarrCfs.repacks ++ radarrCfs.hdr ++ radarrCfs.unwanted;
          assign_scores_to = [{name = movies;}];
        }
      ];
    };

    configuration.sonarr.sonarr = {
      base_url = "http://127.0.0.1:${toString config.services.sonarr.settings.server.port}";
      api_key._secret = config.age.secrets.sonarrApiKey.path;

      media_management.propers_and_repacks = "do_not_prefer";

      # Episode files only; series/season folder formats stay so existing paths don't split.
      media_naming.episodes = {
        rename = true;
        standard = "default";
        daily = "default";
        anime = "default";
      };

      quality_profiles = [
        {
          name = general;
          # Language: Not Original replaces the old "Original Language Only" min-score gate.
          reset_unmatched_scores.enabled = true;
          min_format_score = 0;
          upgrade = {
            allowed = true;
            until_quality = "HD 1080p";
            until_score = 10000;
          };
          # Top first. 1080p WEB/Bluray tie on quality, CF score decides; 4K only as fallback.
          qualities = [
            {
              name = "HD 1080p";
              qualities = ["Bluray-1080p Remux" "Bluray-1080p" "WEBDL-1080p" "WEBRip-1080p"];
            }
            {name = "HDTV-1080p";}
            {name = "Bluray-2160p Remux";}
            {name = "Bluray-2160p";}
            {
              name = "WEB 2160p";
              qualities = ["WEBDL-2160p" "WEBRip-2160p"];
            }
            {name = "HDTV-2160p";}
            {name = "Bluray-720p";}
            {
              name = "WEB 720p";
              qualities = ["WEBDL-720p" "WEBRip-720p"];
            }
          ];
        }
        {
          # Qualities and upgrade rules stay as configured in Sonarr.
          name = any;
          reset_unmatched_scores.enabled = true;
          min_format_score = 0;
        }
      ];

      custom_formats = [
        {
          trash_ids = sonarrCfs.hqGroups ++ sonarrCfs.repacks ++ sonarrCfs.streaming ++ sonarrCfs.unwanted;
          assign_scores_to = [{name = general;} {name = any;}];
        }
      ];
    };
  };

  # Rendered config.yml holds both API keys; module default leaves it world-readable.
  systemd.services.recyclarr.serviceConfig = {
    StateDirectoryMode = "0700";
    UMask = "0077";
  };
}
