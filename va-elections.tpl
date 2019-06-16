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
  </style>
  <script src="https://cdnjs.cloudflare.com/ajax/libs/jquery/3.3.1/jquery.min.js" integrity="sha256-FgpCb/KJQlLNfOu91ta32o/NMZxltwRo8QtmkMRdAu8=" crossorigin="anonymous"></script>
  <script type="text/javascript" charset="utf8" src="https://cdn.datatables.net/1.10.19/js/jquery.dataTables.min.js"></script>
  <script type="text/javascript" charset="utf8" src="https://cdn.datatables.net/fixedheader/3.1.5/js/dataTables.fixedHeader.min.js"></script>
  <script type="text/javascript">
    jQuery(function () {
      var numberCol = {
          className: 'number',
          render: $.fn.dataTable.render.number(',', '.')
        },
        marginCol = {
          className: 'number',
          render: function (value, type) {
            value = +value;
            return type === 'display' ? (value > 0 ? '+' : value < 0 ? '−' : '') + Math.abs(value) : value;
          }
        };
      $('#races-table').DataTable({
        columns: [
          {
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
          null,
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
    });
  </script>
</head>
<body>
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
        <td><%- district %></td>
        <% _.forEach(r, function (value, key) { %>
          <td<% if (/Margin/.test(key)) { %> <%= marginStyle(value) %><% }
            else if (key === 'Party') { %> class="<%= value === 'D' ? 'democrat' : 'republican' %>"<% }
            else if (Array.isArray(value) && !value.length) { %> class="empty"<% } %>
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
