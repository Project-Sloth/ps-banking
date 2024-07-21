<script lang="ts">
  import VisibilityProvider from "./providers/VisibilityProvider.svelte";
  import Main from "./components/Main.svelte";
  import { debugData } from "./utils/debugData";
  import { slide, fade } from "svelte/transition";
  import { notifications, showATM } from "../src/store/data";
  import { visibility } from "../src/store/stores";

  debugData([
    {
      action: "openBank",
      data: true,
    },
  ]);
</script>

<main>
  <VisibilityProvider>
    <Main />
  </VisibilityProvider>
  {#if $showATM}
    <div
      class="absolute bottom-44 right-[22%] grid grid-cols-1 gap-2 select-none"
    >
      {#each $notifications as notification (notification.id)}
        <div
          class="bg-gray-900 text-blue-200 py-3 px-6 rounded-lg shadow-xl flex items-center space-x-3 transform transition-transform duration-500 border border-gray-700/50"
          in:slide={{ duration: 300 }}
          out:fade={{ duration: 300 }}
        >
          <i class="fa-duotone fa-{notification.icon} text-2xl"></i>
          <div>
            <p class="font-bold">{notification.title}</p>
            <p>{notification.message}</p>
          </div>
        </div>
      {/each}
    </div>
  {:else}
    <div
      class="absolute bottom-24 right-[12%] grid grid-cols-1 gap-2 select-none"
    >
      {#each $notifications as notification (notification.id)}
        <div
          class="bg-gray-900 text-blue-200 py-3 px-6 rounded-lg shadow-xl flex items-center space-x-3 transform transition-transform duration-500 border border-gray-700/50"
          in:slide={{ duration: 300 }}
          out:fade={{ duration: 300 }}
        >
          <i class="fa-duotone fa-{notification.icon} text-2xl"></i>
          <div>
            <p class="font-bold">{notification.title}</p>
            <p>{notification.message}</p>
          </div>
        </div>
      {/each}
    </div>
  {/if}
</main>
