<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>Virginia 2019 Elections</title>
  <link rel="stylesheet" type="text/css" href="https://cdn.datatables.net/1.10.19/css/jquery.dataTables.min.css">
  <link rel="stylesheet" type="text/css" href="https://cdn.datatables.net/fixedheader/3.1.5/css/fixedHeader.dataTables.min.css">
  <style type="text/css">
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
      background-color: lightgray;
    }
    .number {
      text-align: right;
    }
    #controls {
      position: absolute;
      z-index: 100;
    }
    table.dataTable {
      width: auto;
      margin: 0;
    }
  </style>
  <script src="https://cdnjs.cloudflare.com/ajax/libs/jquery/3.3.1/jquery.min.js" integrity="sha256-FgpCb/KJQlLNfOu91ta32o/NMZxltwRo8QtmkMRdAu8=" crossorigin="anonymous"></script>
  <script type="text/javascript" charset="utf8" src="https://cdn.datatables.net/1.10.19/js/jquery.dataTables.min.js"></script>
  <script type="text/javascript" charset="utf8" src="https://cdn.datatables.net/fixedheader/3.1.5/js/dataTables.fixedHeader.min.js"></script>
  <script type="text/javascript">
    jQuery(function () {
      var numberCol = {
          className: 'number',
          visible: false,
          render: $.fn.dataTable.render.number(',', '.')
        },
        marginCol = {
          className: 'number',
          width: 30,
          render: function (value, type) {
            if (value === '') {
              return '';
            }
            value = +value;
            return type === 'display' ? (value > 0 ? '+' : value < 0 ? '−' : '') + Math.abs(value) : value;
          }
        },
        table;
      $.fn.dataTable.ext.search.push(
        function (settings, searchData, index, rowData, counter) {
          if ($('#show-uncontested').prop('checked')) {
            return true;
          }
          return searchData[1] && searchData[2];
        }
      );
      table = $('#races-table').DataTable({
        columns: [
          {
            width: 20,
            render: function (value, type) {
              var m;
              if (type === 'sort') {
                m = value.match(/^([HS]D)(\d+)$/);
                if (m) {
                  return m[1] + m[2].padStart(3, '0');
                }
              }
              return value;
            }
          },
          null,
          null,
          null,
          null,
          {width: 20},
          numberCol,
          numberCol,
          marginCol,
          numberCol,
          numberCol,
          marginCol,
          numberCol,
          numberCol,
          marginCol,
          numberCol,
          numberCol,
          marginCol,
          numberCol,
          numberCol,
          marginCol
        ],
        fixedHeader: true,
        paging: false
      });
      $('#show-uncontested').on('click', function () { table.draw(); });
      $('#show-vote-totals').on('click', function () {
        table.columns([6, 7, 9, 10, 12, 13, 15, 16, 18, 19]).visible($(this).prop('checked'));
      });
    });
  </script>
</head>
<body>
<div id="controls">
  <input type="checkbox" id="show-uncontested"> Show uncontested races
  <input type="checkbox" id="show-vote-totals"> Show vote totals
</div>
<table id="races-table">
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
</body>
</html>
