<script>
  let currentPage = 1;
  let comments = $state([]);
  let uriName = $state(null);
  let uri = $state("");
  let decodedUri = $state("");

  function decodeHex(hexString) {
    // Remove any spaces, 0x prefix, or other non-hex characters
    const cleanHex = hexString.replace(/[^0-9A-Fa-f]/g, "");

    // Convert hex string to byte array
    const bytes = new Uint8Array(cleanHex.match(/.{1,2}/g).map((byte) => parseInt(byte, 16)));

    // Decode bytes to UTF-8 string
    const decoder = new TextDecoder("utf-8");
    return decoder.decode(bytes);
  }
  import { onMount } from "svelte";
  onMount(async () => {
    await loadComments();
  });

  const loadComments = async () => {
    comments.length = 0;
    const qp = new URLSearchParams(window.location.search);
    uri = qp.get("uri") || qp.get("uri_encoded");
    uriName = qp.get("uri") ? "uri" : "uri_encoded";
    if (!uri) {
      return;
    }
    decodedUri = uriName === "uri" ? uri : decodeHex(uri);

    const data = await (
      await fetch(`http://localhost:8000/comments?${uriName}=${uri}&page=${currentPage}`)
    ).json();
    console.log(data);
    comments.push(...data.comments);
  };
  let commentInput = $state("");
  let nicknameInput = $state("");
  let emailInput = $state("");
  const createComment = async (event) => {
    const btn = document.querySelector("#submit-comment-button");
    btn.disabled = "disabled";
    btn.innerHTML = "Loading...";
    event.preventDefault();
    const data = {
      nickname: nicknameInput,
      email: emailInput,
      content: commentInput,
    };
    data[uriName] = uri;
    const response = await fetch(
      `http://localhost:8000/comments?${uriName}=${uri}&page=${currentPage}`,
      {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify(data),
      }
    );
    if (response.status > 201) {
      alert("failed");
    }

    await loadComments();
    commentInput = "";
    nicknameInput = "";
    emailInput = "";

    btn.disabled = "";
    btn.innerHTML = "Submit";
  };
</script>

<h1>Commenturi FE</h1>
<h2>Current URI: {decodedUri}</h2>
{#each comments as { content, nickname, email }}
  <p><span>{nickname}&lt;{email}&gt;</span>: <span>{content}</span></p>
{/each}
<hr />
<form onsubmit={createComment}>
  nickname: <input type="text" bind:value={nicknameInput} /><br />
  email: <input type="email" bind:value={emailInput} /><br />
  comment: <textarea bind:value={commentInput}></textarea><br />
  <button type="submit" id="submit-comment-button">Submit</button>
</form>
