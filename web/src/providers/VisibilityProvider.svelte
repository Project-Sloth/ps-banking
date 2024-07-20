<script lang="ts">
  import { useNuiEvent } from "../utils/useNuiEvent";
  import { fetchNui } from "../utils/fetchNui";
  import { onMount } from "svelte";
  import { visibility } from "../store/stores";
  import ATM from "../components/ATM.svelte";
  import { showATM } from "../store/data";

  let isVisible: boolean;

  useNuiEvent<boolean>("openATM", () => {
    showATM.set(true);
  });

  visibility.subscribe((visible) => {
    isVisible = visible;
  });

  useNuiEvent<boolean>("openBank", () => {
    visibility.set(true);
  });
  useNuiEvent<boolean>("hideGarageMenu", () => {
    visibility.set(false);
  });
  onMount(() => {
    const keyHandler = (e: KeyboardEvent) => {
      if (isVisible && ["Escape"].includes(e.code)) {
        fetchNui("ps-banking:client:hideUI");
        visibility.set(false);
      }
    };

    window.addEventListener("keydown", keyHandler);

    return () => window.removeEventListener("keydown", keyHandler);
  });
</script>

<main>
  {#if isVisible}
    <slot />
  {/if}
  {#if $showATM}
    <ATM />
  {/if}
</main>
