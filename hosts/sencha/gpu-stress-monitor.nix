# Diagnostic harness for the RTX A1000 "Xid 79 GPU has fallen off the bus" fault.
#
# Exposes three commands (system-wide):
#   gpu-stress-monitor-start  – start telemetry/kernel logging in the background
#   gpu-stress-monitor-stop   – stop a running background monitor (only useful if
#                               the laptop did NOT crash; a crash ends it anyway)
#   gpu-stress-test           – run GPU stressors in the foreground
#
# Logs go to /tmp/gpu-stress-monitor/. On sencha /tmp lives on the root fs and is
# not cleaned on boot, so the telemetry survives a hard power-off + reboot — point
# Claude at that directory afterwards. The kernel Xid signature is also always
# recoverable from `journalctl -b -1 -k`.
{
  config,
  pkgs,
  ...
}: let
  logDir = "/tmp/gpu-stress-monitor";
  pidFile = "${logDir}/monitor.pid";

  # nvidia-smi ships in the driver package's "bin" output.
  nvidiaBin = config.hardware.nvidia.package.bin;

  start = pkgs.writeShellApplication {
    name = "gpu-stress-monitor-start";
    runtimeInputs = [nvidiaBin pkgs.coreutils pkgs.gnugrep pkgs.systemd pkgs.util-linux pkgs.bash];
    text = ''
      logdir="${logDir}"
      pidfile="${pidFile}"

      if [ -f "$pidfile" ]; then
        oldpid="$(cat "$pidfile" 2>/dev/null || true)"
        if [ -n "$oldpid" ] && kill -0 "$oldpid" 2>/dev/null; then
          echo "GPU monitor already running (pid $oldpid)." >&2
          echo "Stop it first with: gpu-stress-monitor-stop" >&2
          exit 1
        fi
      fi

      mkdir -p "$logdir"

      # All monitors run inside one detached session so the whole process group
      # can be stopped together. setsid execs bash here (job control is off in a
      # script), so $! is the session/group leader pid.
      # shellcheck disable=SC2016
      LOGDIR="$logdir" setsid bash -c '
        cd "$LOGDIR" || exit 1
        echo "# monitor started $(date "+%F %T")" >> session.log

        # 1s telemetry: power/temp, util, clocks, violations, memory, ecc+pcie
        # errors, pcie throughput (+ date/time columns).
        stdbuf -oL nvidia-smi dmon -s pucvmet -o DT >> dmon.log 2>&1 &

        # 5s detail incl. pstate + PCIe link gen/width. A link drop here is the
        # tell-tale that precedes "GPU has fallen off the bus".
        echo "# time, temp_C, power_W, sm_MHz, mem_MHz, pstate, pcie_gen, pcie_width, gpu_util, mem_util" >> smi-query.log
        while true; do
          { date "+%F %T"; nvidia-smi --query-gpu=temperature.gpu,power.draw,clocks.sm,clocks.mem,pstate,pcie.link.gen.current,pcie.link.width.current,utilization.gpu,utilization.memory --format=csv,noheader; } >> smi-query.log 2>&1
          sleep 5
        done &

        # Live kernel watch for the fatal signatures.
        stdbuf -oL journalctl -kf -n0 2>/dev/null | stdbuf -oL grep -iE "Xid|fallen off|NVRM|nvidia-modeset.*ERROR|drm.*ERROR" >> kernel.log 2>&1 &

        # Flush every 3s so a hard power-off keeps the telemetry tail.
        while true; do sync; sleep 3; done &

        wait
      ' &

      monpid=$!
      echo "$monpid" > "$pidfile"

      echo "GPU monitor started (session pid $monpid)."
      echo "Logs:  $logdir/"
      echo "Stop:  gpu-stress-monitor-stop"
    '';
  };

  stop = pkgs.writeShellApplication {
    name = "gpu-stress-monitor-stop";
    runtimeInputs = [pkgs.coreutils];
    text = ''
      pidfile="${pidFile}"

      if [ ! -f "$pidfile" ]; then
        echo "No monitor pidfile ($pidfile). Nothing to stop."
        exit 0
      fi

      pid="$(cat "$pidfile" 2>/dev/null || true)"
      if [ -z "$pid" ]; then
        echo "Pidfile empty. Nothing to stop."
        rm -f "$pidfile"
        exit 0
      fi

      if kill -0 "$pid" 2>/dev/null; then
        # Negative pid = kill the whole process group (session leader == pgid).
        kill -TERM -"$pid" 2>/dev/null || kill -TERM "$pid" 2>/dev/null || true
        sleep 1
        kill -KILL -"$pid" 2>/dev/null || true
        echo "Stopped GPU monitor (pid $pid)."
      else
        echo "GPU monitor not running (stale pid $pid)."
      fi
      rm -f "$pidfile"
    '';
  };

  test = pkgs.writeShellApplication {
    name = "gpu-stress-test";
    runtimeInputs = [pkgs.vkmark pkgs.glmark2];
    text = ''
      # Force rendering onto the NVIDIA GPU (PRIME offload) — same env the
      # `nvidia-offload` wrapper sets.
      export __NV_PRIME_RENDER_OFFLOAD=1
      export __NV_PRIME_RENDER_OFFLOAD_PROVIDER=NVIDIA-G0
      export __GLX_VENDOR_LIBRARY_NAME=nvidia
      export __VK_LAYER_NV_optimus=NVIDIA_only

      echo "Stressing the NVIDIA GPU render path (the one that crashed)."
      echo "Drag each benchmark window onto your EXTERNAL monitor and fullscreen it."
      echo "Ctrl-C to stop."
      echo

      trap 'echo; echo "Stopping stressors."; exit 0' INT TERM

      while true; do
        echo "=== vkmark (Vulkan / DXVK path) ==="
        vkmark || true
        echo "=== glmark2 (OpenGL / EGL path) ==="
        glmark2 || true
      done
    '';
  };
in {
  environment.systemPackages = [start stop test];
}
