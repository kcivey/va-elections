<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
  <title>Virginia 2019 Elections</title>
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/twitter-bootstrap/4.3.1/css/bootstrap.min.css" integrity="sha256-YLGeXaapI0/5IgZopewRJcFXomhRMlYYjugPLSyNjTY=" crossorigin="anonymous" />
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.8.1/css/all.min.css" integrity="sha256-7rF6RaSKyh16288E3hVdzQtHyzatA2MQRGu0cf6pqqM=" crossorigin="anonymous" />
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/datatables/1.10.19/css/dataTables.bootstrap4.min.css" integrity="sha256-F+DaKAClQut87heMIC6oThARMuWne8+WzxIDT7jXuPA=" crossorigin="anonymous" />
  <link rel="stylesheet" type="text/css" href="https://cdn.datatables.net/fixedheader/3.1.5/css/fixedHeader.dataTables.min.css">
  <link rel="stylesheet" href="/index.css" />
  <style type="text/css">
    table {
      background-color: white;
    }
    .democrat {
      font-weight: bold;
      color: white;
      text-align: center;
      background-color: blue;
    }
    .republican {
      font-weight: bold;
      color: white;
      text-align: center;
      background-color: red;
    }
    .empty {
      background-color: #eee;
    }
    .number {
      text-align: right;
    }
    .center {
      text-align: center;
    }
    #controls {
      position: absolute;
      z-index: 100;
    }
    .control-group {
      display: inline-block;
      margin-right: 1rem;
    }
    table.dataTable {
      width: auto;
      margin: 0;
    }
  </style>
</head>
<body>
<h1>Virginia 2019 Elections</h1>
<div id="controls">
  <div class="control-group">
    <div class="form-check form-check-inline">
      <input type="checkbox" id="show-uncontested" class="form-check-input">
      <label class="form-check-label" for="show-uncontested">Show uncontested races</label>
    </div>
  </div>
  <div class="control-group">
    <div class="form-check form-check-inline">
      <input type="checkbox" id="show-vote-totals" class="form-check-input">
      <label class="form-check-label" for="show-vote-totals">Show vote totals</label>
    </div>
  </div>
  <div class="control-group">
    <div id="show-chamber" class="form-check form-check-inline">
      <input type="radio" id="show-chamber-1" class="form-check-input" name="chamber" value="senate">
      <label class="form-check-label" for="show-chamber-1">Senate</label>
    </div>
    <div id="show-chamber" class="form-check form-check-inline">
      <input type="radio" id="show-chamber-2" class="form-check-input" name="chamber" value="house">
      <label class="form-check-label" for="show-chamber-2">House</label>
    </div>
    <div id="show-chamber" class="form-check form-check-inline">
      <input type="radio" id="show-chamber-3" class="form-check-input" name="chamber" value="both" checked>
      <label class="form-check-label" for="show-chamber-3">Both</label>
    </div>
  </div>
</div>
<table id="races-table" class="table">
  <thead>
    <tr>
      <% _.forEach(headers, function (header) { %>
        <th><%- header %></th>
      <% }); %>
    </tr>
  </thead>
  <tbody>
    <% _.forEach(data, function (r, district) { %>
      <tr>
        <% _.forEach(headers, function (key) { %>
          <% var value = key === 'District' ? district : r[key]; %>
          <td<% if (/Margin/.test(key)) { %> <%= marginStyle(value) %><% }
            else if (key === 'Party') { %> class="<%= {D: 'democrat', R: 'republican'}[value] || 'empty' %>"<% }
            else if ((Array.isArray(value) && !value.length) || value == null || value === '') { %> class="empty"<% } %>
          >
            <% if (Array.isArray(value)) { %>
              <% _.forEach(value, function (v) { %>
                <%- v %><br>
              <% }); %>
            <% } else { %>
              <%- value %>
            <% } %>
          </td>
        <% }); %>
      </tr>
    <% }); %>
  </tbody>
</table>
<script src="https://cdnjs.cloudflare.com/ajax/libs/jquery/3.4.0/jquery.slim.min.js" integrity="sha256-ZaXnYkHGqIhqTbJ6MB4l9Frs/r7U4jlx7ir8PJYBqbI=" crossorigin="anonymous"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.15.0/umd/popper.min.js" integrity="sha256-fTuUgtT7O2rqoImwjrhDgbXTKUwyxxujIMRIK7TbuNU=" crossorigin="anonymous"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/twitter-bootstrap/4.3.1/js/bootstrap.min.js" integrity="sha256-CjSoeELFOcH0/uxWu6mC/Vlrc1AARqbm/jiiImDGV3s=" crossorigin="anonymous"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/datatables/1.10.19/js/jquery.dataTables.min.js" integrity="sha256-t5ZQTZsbQi8NxszC10CseKjJ5QeMw5NINtOXQrESGSU=" crossorigin="anonymous"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/datatables/1.10.19/js/dataTables.bootstrap4.min.js" integrity="sha256-hJ44ymhBmRPJKIaKRf3DSX5uiFEZ9xB/qx8cNbJvIMU=" crossorigin="anonymous"></script>
<script src="https://cdn.datatables.net/fixedheader/3.1.5/js/dataTables.fixedHeader.min.js"></script>
<script type="text/javascript">
  jQuery(function () {
    const districtCol = {
      width: 20,
      render: function (value, type) {
        if (type === 'sort') {
          const m = value.match(/^([HS]D)(\d+)$/);
          if (m) {
            return m[1] + m[2].padStart(3, '0');
          }
        }
        return value;
      }
    };
    const openCol = {
      className: 'center',
      width: 20,
      render: function (value, type) {
        return value === 'true' ? '\u2713' : '';
      },
    };
    const numberCol = {
      className: 'number',
      visible: false,
      render: $.fn.dataTable.render.number(',', '.')
    };
    const marginCol = {
      className: 'number',
      width: 30,
      render: function (value, type) {
        if (value === '') {
          return '';
        }
        value = +value;
        return type === 'display' ? (value > 0 ? '+' : value < 0 ? '−' : '') + Math.abs(value) : value;
      }
    };
    $.fn.dataTable.ext.search.push(
      function (settings, searchData) {
        if ($('#show-uncontested').prop('checked')) {
          return true;
        }
        return searchData[1] && searchData[2];
      },
      function (settings, searchData) {
        const chamber = $('#show-chamber input:checked').val();
        switch (chamber) {
          case 'house':
            return searchData[0].substr(0, 1) === 'H';
          case 'senate':
            return searchData[0].substr(0, 1) === 'S';
          default:
            return true;
        }
      }
    );
    const $table = $('#races-table')
            .on('draw.dt', () => $('#races-table_wrapper').width($table.width()));
    const table = $table.DataTable({
      columns: [
        <% _.forEach(headers, function (header) {
          if (header === 'District') { %>districtCol<% }
          else if (header === 'Party') { %>{width: 20}<% }
          else if (header === 'Open') { %>openCol<% }
          else if (/\b(?:Votes|D|R)$/.test(header)) { %>numberCol<% }
          else if (/Margin$/.test(header)) { %>marginCol<% }
          else { %>null<% } %>,
        <% }); %>
      ],
      fixedHeader: true,
      paging: false
    });
    $('#show-uncontested').on('click', function () { table.draw(); });
    $('#show-chamber input').on('change', function () { table.draw(); });
    const hiddenColumns = [
      <% _.forEach(headers, function (header, i) {
        if (/\b(?:Votes|D|R)$/.test(header)) { %><%= i %>,<% } %>
      <% }); %>
    ];
    $('#show-vote-totals').on('click', function () {
      table.columns(hiddenColumns).visible($(this).prop('checked'));
    });
  });
</script>
<%= '\x3c%= nav %\x3e' %>
</body>
</html>
