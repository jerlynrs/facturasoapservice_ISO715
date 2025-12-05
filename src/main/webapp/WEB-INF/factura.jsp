<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width,initial-scale=1" />
    <title>Factura — Consulta de Monto</title>
    <style>
        :root{
            --bg:#f4f7fb;
            --card:#ffffff;
            --accent:#0b76d1;
            --muted:#6b7280;
            --success:#1f8a3d;
            --danger:#d32f2f;
            --shadow: 0 8px 24px rgba(11,118,209,0.06);
            --glass: rgba(255,255,255,0.6);
            --radius:12px;
            font-family: Inter, Roboto, "Helvetica Neue", Arial, sans-serif;
        }
        html,body{height:100%;margin:0;background:linear-gradient(180deg,var(--bg),#eef3fb);}
        .container{max-width:980px;margin:40px auto;padding:20px;}
        .card{
            background:var(--card);
            border-radius:var(--radius);
            box-shadow:var(--shadow);
            overflow:hidden;
        }
        header{
            display:flex;
            justify-content:space-between;
            align-items:center;
            padding:22px 28px;
            border-bottom:1px solid #eef2f7;
        }
        header h1{margin:0;font-size:20px;color:#0f172a;}
        header p{margin:0;color:var(--muted);font-size:13px;}
        .topbar{display:flex;gap:12px;align-items:center;}
        .search {
            display:flex; gap:8px; align-items:center;
            background:var(--glass); padding:8px; border-radius:8px;
        }
        .search input{
            border:0; outline:none; font-size:15px; padding:8px; width:160px; background:transparent;
        }
        .btn {
            background:var(--accent); color:white; border:0; padding:10px 14px; border-radius:8px; cursor:pointer;
            font-weight:600;
        }
        .btn.secondary{background:#fff;color:var(--accent);border:1px solid #dbeaf8;}
        main{display:flex; gap:24px; padding:24px;}
        .left, .right{flex:1;}
        .panel{background:linear-gradient(180deg,#fff,#fbfdff); padding:18px; border-radius:10px; box-shadow: 0 4px 12px rgba(2,6,23,0.03);}
        .meta{display:flex;gap:16px;flex-wrap:wrap;}
        .meta div{min-width:150px;}
        .meta label{display:block;font-size:12px;color:var(--muted);margin-bottom:6px;}
        .meta span{font-weight:600;color:#0b1320;}
        table{width:100%;border-collapse:collapse;margin-top:12px;}
        th,td{padding:10px;border-bottom:1px solid #f1f6fb;text-align:left}
        th{background:#f7fbff;color:#0b3555;font-weight:700;}
        tfoot td{font-weight:700;padding-top:14px;border-top:2px solid #eef6ff}
        .total {text-align:right;font-size:18px;color:var(--accent);}
        .status {display:inline-block;padding:6px 10px;border-radius:999px;font-weight:700;font-size:13px}
        .status.green{background:#e6f6ea;color:var(--success);}
        .status.red{background:#fdecea;color:var(--danger);}
        .actions{display:flex;gap:10px;justify-content:flex-end;margin-top:12px;}
        .note{font-size:13px;color:var(--muted);margin-top:8px;}
    </style>
</head>
<body>
<div class="container">
    <div class="card">
        <header>
            <div>
                <h1>Consulta de Factura</h1>
                <p>Introduce el número de factura para ver el monto total</p>
            </div>
            <div class="topbar">
                <div class="search" role="search">
                    <label for="invoice" style="font-size:13px;color:var(--muted);margin-right:6px;">Nº Factura</label>
                    <input id="invoice" type="number" min="1" placeholder="1001" />
                    <button id="btnSearch" class="btn">Ver Factura</button>
                </div>
                <button id="btnPrint" class="btn secondary">Imprimir</button>
            </div>
        </header>

        <main>
            <section class="left">
                <div class="panel" id="panelInvoice">
                    <!-- Datos -->
                    <div id="invoiceContent">
                        <div style="display:flex;justify-content:space-between;align-items:center">
                            <div class="meta">
                                <div><label>Factura</label><span id="f_id">—</span></div>
                                <div><label>Cliente</label><span id="f_client">—</span></div>
                                <div><label>Fecha</label><span id="f_date">—</span></div>
                            </div>
                            <div>
                                <label style="font-size:12px;color:var(--muted)">Estado</label>
                                <div id="f_status"><span class="status green">VIGENTE</span></div>
                            </div>
                        </div>

                        <table id="itemsTable">
                            <thead>
                            <tr>
                                <th>Artículo</th>
                                <th>Precio unit.</th>
                                <th>Cant.</th>
                                <th>Subtotal</th>
                            </tr>
                            </thead>
                            <tbody></tbody>
                            <tfoot>
                            <tr>
                                <td colspan="3" class="total">Total</td>
                                <td id="grandTotal" class="total">$0.00</td>
                            </tr>
                            </tfoot>
                        </table>

                        <div class="note" id="noteArea"></div>
                    </div>
                </div>
            </section>

            <aside class="right">
                <div class="panel">
                    <h3 style="margin:0 0 12px 0">Resumen rápido</h3>
                    <p><strong>Facturas cargadas:</strong> 2</p>
                    <p><strong>Última consulta:</strong> <span id="lastQuery">—</span></p>
                    <p><strong>Total mostrado:</strong> <span id="lastTotal">$0.00</span></p>
                </div>
            </aside>
        </main>
    </div>
</div>

<script>
    const FIXED_DB = {
        1001: {
            id:1001,
            client:'Cliente Genérico',
            date:'2025-12-05',
            items:[
                {desc:'Artículo 1', price:200.00, qty:2},
                {desc:'Artículo 2', price:150.50, qty:1},
                {desc:'Artículo 3', price:99.99, qty:3}
            ]
        },
        1002: {
            id:1002,
            client:'Cliente Genérico',
            date:'2025-12-05',
            items:[
                {desc:'Artículo 1', price:500.00, qty:1}
            ]
        }
    };

    const invoiceInput = document.getElementById('invoice');
    const itemsTB = document.querySelector("#itemsTable tbody");
    const f_id = document.getElementById("f_id");
    const f_client = document.getElementById("f_client");
    const f_date = document.getElementById("f_date");
    const grandTotalEl = document.getElementById("grandTotal");
    const lastQuery = document.getElementById("lastQuery");
    const lastTotal = document.getElementById("lastTotal");
    const noteArea = document.getElementById("noteArea");
    const f_status = document.getElementById("f_status");

    function formatMoney(v){ return "$" + v.toFixed(2); }

    function renderInvoice(inv){
        f_id.textContent = inv.id;
        f_client.textContent = inv.client;
        f_date.textContent = inv.date;

        itemsTB.innerHTML = "";
        let total = 0;

        inv.items.forEach(it=>{
            const sub = it.price * it.qty;
            total += sub;

            const tr = document.createElement("tr");
            tr.innerHTML = `
      <td>${it.desc}</td>
      <td>${formatMoney(it.price)}</td>
      <td>${it.qty}</td>
      <td>${formatMoney(sub)}</td>`;
            itemsTB.appendChild(tr);
        });

        grandTotalEl.textContent = formatMoney(total);
        lastTotal.textContent = formatMoney(total);
        lastQuery.textContent = new Date().toLocaleString();
        noteArea.textContent = "Monto calculado correctamente desde los datos registrados.";
    }

    document.getElementById("btnSearch").onclick = ()=>{
        const id = Number(invoiceInput.value);
        if(!id){ return; }

        const inv = FIXED_DB[id];

        if(inv){
            renderInvoice(inv);
            f_status.innerHTML = '<span class="status green">VIGENTE</span>';
        } else {
            itemsTB.innerHTML = "";
            f_id.textContent = id;
            f_client.textContent = '—';
            f_date.textContent = '—';
            grandTotalEl.textContent = "$0.00";
            f_status.innerHTML = '<span class="status red">NO ENCONTRADA</span>';
            noteArea.textContent = "No existe una factura con ese número.";
        }
    };

    document.getElementById("btnPrint").onclick = ()=> window.print();

</script>

</body>
</html>
