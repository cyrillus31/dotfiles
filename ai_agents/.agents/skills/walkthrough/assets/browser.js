"use strict";


function drawGraph(canvas) {
  const graph = JSON.parse(canvas.dataset.graph);
  const width = canvas.clientWidth;
  if (!width) return;
  const height = Math.max(150, Math.min(410, graph.nodes.length * 38 + 80));
  const scale = window.devicePixelRatio || 1;
  canvas.width = width * scale;
  canvas.height = height * scale;
  canvas.style.height = `${height}px`;
  const context = canvas.getContext("2d");
  context.scale(scale, scale);
  const nodeWidth = Math.min(130, Math.max(55, width * (graph.nodes.length > 6 ? .19 : .28)));
  const nodeHeight = 32;
  const positions = new Map(graph.nodes.map((name, index) => {
    if (graph.nodes.length === 1) return [name, [width / 2, height / 2]];
    const angle = Math.PI + 2 * Math.PI * index / graph.nodes.length;
    return [name, [
      width / 2 + Math.cos(angle) * (width / 2 - nodeWidth / 2 - 8),
      height / 2 + Math.sin(angle) * (height / 2 - nodeHeight - 8),
    ]];
  }));

  for (const [index, [source, , target]] of graph.edges.entries()) {
    const [startX, startY] = positions.get(source);
    const [endX, endY] = positions.get(target);
    const dx = endX - startX;
    const dy = endY - startY;
    const angle = Math.atan2(dy, dx);
    context.strokeStyle = "#9db6df";
    context.lineWidth = 1.5;
    context.beginPath();
    if (source === target) {
      context.arc(startX, startY - 24, 16, 0, Math.PI * 2);
    } else {
      const endDistance = Math.max(Math.abs(dx) / (nodeWidth / 2), Math.abs(dy) / (nodeHeight / 2));
      const arrowX = endX - dx / endDistance;
      const arrowY = endY - dy / endDistance;
      context.moveTo(startX, startY);
      context.lineTo(arrowX, arrowY);
      context.lineTo(arrowX - 8 * Math.cos(angle - .5), arrowY - 8 * Math.sin(angle - .5));
      context.moveTo(arrowX, arrowY);
      context.lineTo(arrowX - 8 * Math.cos(angle + .5), arrowY - 8 * Math.sin(angle + .5));
    }
    context.stroke();
    context.fillStyle = "#dbe7ff";
    context.font = "bold 11px system-ui";
    context.textAlign = "center";
    context.fillText(index + 1, (startX + endX) / 2, (startY + endY) / 2 - (source === target ? 38 : 5));
  }

  for (const [name, [x, y]] of positions) {
    context.fillStyle = "#38578d";
    context.beginPath();
    context.roundRect(x - nodeWidth / 2, y - nodeHeight / 2, nodeWidth, nodeHeight, 7);
    context.fill();
    context.fillStyle = "#fffdf6";
    context.font = "12px system-ui";
    context.textAlign = "center";
    context.textBaseline = "middle";
    context.fillText(name, x, y, nodeWidth - 10);
  }
}

const graphObserver = new ResizeObserver((entries) => {
  for (const { target } of entries) drawGraph(target.querySelector("canvas"));
});

function observeGraphs(root) {
  for (const canvas of root.querySelectorAll("canvas[data-graph]")) {
    drawGraph(canvas);
    graphObserver.observe(canvas.parentElement);
  }
}

observeGraphs(document);

const clarificationInput = document.querySelector("#clarification-question");
clarificationInput.addEventListener("keydown", (event) => {
  if (event.key !== "Enter" || event.shiftKey || event.isComposing) return;
  event.preventDefault();
  const submitButton = clarificationInput.form.querySelector('button[type="submit"]');
  if (!event.repeat && !submitButton.disabled && clarificationInput.value.trim()) {
    clarificationInput.form.requestSubmit(submitButton);
  }
});

document.body.addEventListener("htmx:afterSwap", (event) => {
  if (event.detail.target.id === "chat") observeGraphs(event.detail.target);
});

document.body.addEventListener("htmx:afterRequest", (event) => {
  if (event.detail.elt.id === "clarification" &&
      event.detail.xhr.responseText.startsWith("<article")) {
    clarificationInput.value = "";
  }
});

document.body.addEventListener("htmx:beforeSwap", (event) => {
  if (event.detail.target.id === "answer-status" &&
      event.detail.target.innerHTML === event.detail.serverResponse) {
    event.detail.shouldSwap = false;
  }
});

document.body.addEventListener("htmx:beforeOnLoad", (event) => {
  if (event.detail.xhr.getResponseHeader("HX-Refresh") === "true") {
    window.scrollTo(0, 0);
  }
});
