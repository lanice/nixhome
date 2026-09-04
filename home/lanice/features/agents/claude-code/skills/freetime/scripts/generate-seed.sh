#!/usr/bin/env bash
# Generates random creative seeds to inspire a freetime research session.
# Run this at the start of each session for a unique starting point.

set -euo pipefail

# --- Word pool ---
# Pull random words from the system dictionary, filtering for interesting length
random_words() {
    local count="${1:-3}"
    if [[ -f /usr/share/dict/words ]]; then
        grep -E '^[a-z]{5,12}$' /usr/share/dict/words | shuf -n "$count"
    else
        # Built-in pool of evocative words for environments without a dictionary
        local WORDS=(
            amber archive basilisk bloom calcify canopy cipher crystal delta
            dormant eclipse ember filament glacier glyph harbor igneous jade
            kinetic labyrinth lattice meridian mosaic nebula obsidian oracle
            paradox quartz remnant ripple scaffold shadow sigil spiral tangle
            threshold tremor umbra vellum vertex vortex wander zenith alloy
            beacon chimera dapple effigy fennel gradient hollow iridescent
            junction kelp lumen mirage nocturne opaque patina quarry resonance
            silhouette terrain undertow vessel waypoint xeric yearn zephyr
            fossil plume synapse tributary abyss bramble conduit diffuse
            estuary fracture geode helix infinite junction knot luminous
            membrane nexus oscillate prism quiver saffron tessellate
        )
        shuf -e "${WORDS[@]}" | head -n "$count"
    fi
}

# --- Domain/discipline pools ---
DOMAINS=(
    "mathematics" "linguistics" "mycology" "archaeology" "oceanography"
    "musicology" "epidemiology" "volcanology" "cryptography" "entomology"
    "paleontology" "acoustics" "cartography" "metallurgy" "semiotics"
    "astrobiology" "glaciology" "numismatics" "dendrochronology" "tribology"
    "forensics" "ethology" "speleology" "geomorphology" "psychoacoustics"
    "biomimicry" "ethnobotany" "astrochemistry" "urban planning" "game theory"
    "fluid dynamics" "behavioral economics" "historical climatology"
    "materials science" "computational biology" "cultural anthropology"
    "network theory" "information theory" "philosophy of mind" "soil science"
)

LENSES=(
    "failures and disasters"
    "unsolved mysteries"
    "things most people get wrong about"
    "the forgotten history of"
    "the smallest possible scale of"
    "what happens at the extremes of"
    "the unexpected economics of"
    "the mathematics hidden inside"
    "controversies within"
    "things that were only recently discovered about"
    "the strangest examples of"
    "connections between this and music"
    "how this looked 500 years ago"
    "the role of accidents and luck in"
    "what practitioners wish outsiders understood about"
    "the tools and instruments of"
    "dead ends and abandoned theories in"
    "the biggest open questions in"
    "how children understand this differently"
    "the sensory experience of"
)

REGIONS=(
    "Sub-Saharan Africa" "Central Asia" "Polynesia" "the Arctic"
    "the Andes" "Southeast Asia" "the Caucasus" "Mesopotamia"
    "Scandinavia" "the Caribbean" "Patagonia" "the Silk Road"
    "the Indian Ocean rim" "Mesoamerica" "the Sahel" "Oceania"
    "the Balkans" "the Malay Archipelago" "the Great Rift Valley"
    "the Tibetan Plateau" "the Amazon Basin" "the Mediterranean"
)

ERAS=(
    "before 1000 BCE" "the Bronze Age" "the Islamic Golden Age"
    "the European Middle Ages" "the Song Dynasty" "the 1400s"
    "the Enlightenment" "the Industrial Revolution" "the 1920s"
    "the Cold War era" "the 1970s" "the early internet era (1990s)"
    "the last five years" "the deep future" "the Cambrian explosion"
    "the last ice age" "the year 1000 CE" "the 17th century"
)

CONSTRAINTS=(
    "but only look at primary sources or original research"
    "and try to find at least one thing that contradicts common knowledge"
    "and focus on the people involved, not just the ideas"
    "but approach it from a completely different field's perspective"
    "and pay special attention to what's still unknown"
    "and look for the weirdest edge case you can find"
    "and trace how the understanding of this has changed over time"
    "but focus on the physical/material aspects, not the abstract"
    "and find someone currently working on this — what are they doing?"
    "and look for a connection to something from a previous session"
)

# --- Pick random elements ---
pick() {
    local -n arr=$1
    echo "${arr[RANDOM % ${#arr[@]}]}"
}

# --- Parse arguments ---
YAML_OUT=""
while [[ $# -gt 0 ]]; do
    case "$1" in
        --yaml) YAML_OUT="$2"; shift 2 ;;
        *) shift ;;
    esac
done

# --- Generate the seed card ---
WORDS=$(random_words 3 | tr '\n' ', ' | sed 's/, *$//')
DOMAIN1=$(pick DOMAINS)
DOMAIN2=$(pick DOMAINS)
# Ensure domain2 != domain1
while [[ "$DOMAIN2" == "$DOMAIN1" ]]; do
    DOMAIN2=$(pick DOMAINS)
done
LENS=$(pick LENSES)
REGION=$(pick REGIONS)
ERA=$(pick ERAS)
CONSTRAINT=$(pick CONSTRAINTS)

# --- Write YAML if requested ---
if [[ -n "$YAML_OUT" ]]; then
    # Split comma-separated words into YAML list
    IFS=',' read -ra WORD_ARR <<< "$WORDS"
    mkdir -p "$(dirname "$YAML_OUT")"
    cat > "$YAML_OUT" <<YAMLEOF
words:
$(for w in "${WORD_ARR[@]}"; do echo "  - $(echo "$w" | xargs)"; done)
domains:
  - "${DOMAIN1}"
  - "${DOMAIN2}"
lens: "${LENS}"
region: "${REGION}"
era: "${ERA}"
constraint: "${CONSTRAINT}"
YAMLEOF
fi

cat <<EOF
╔══════════════════════════════════════════════════════════╗
║              FREETIME RESEARCH — SEED CARD              ║
╠══════════════════════════════════════════════════════════╣
║                                                          ║
║  Random words:    ${WORDS}
║  Domain pairing:  ${DOMAIN1} × ${DOMAIN2}
║  Lens:            ${LENS}
║  Region:          ${REGION}
║  Era:             ${ERA}
║  Constraint:      ${CONSTRAINT}
║                                                          ║
╠══════════════════════════════════════════════════════════╣
║  These are sparks, not assignments. Use any, all, or    ║
║  none — but let them nudge you away from your defaults. ║
╚══════════════════════════════════════════════════════════╝
EOF
