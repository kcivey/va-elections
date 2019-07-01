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
    table.dataTable.fixedHeader-floating {
      margin-top: 0 !important;
    }
    p {
      max-width: 60rem;
    }
  </style>
</head>
<body>
<h1>Virginia 2019 Elections</h1>
<p>
  The 2017 gubernatorial and 2016 presidential numbers come from
  <a href="https://docs.google.com/spreadsheets/d/1YZRfFiCDBEYB7M18fDGLH8IrmyMQGdQKqpOu9lLvmdo/edit#gid=134618696">a spreadsheet compiled by Daily Kos Elections</a>,
  which has been adjusted for the new district lines, which do not affect Northern Virginia (NoVa). The rest comes from the
  <a href="https://www.vpap.org/elections/">Virginia Public Access Project</a>.
  Margins are calculated from the Democratic and Republican votes, ignoring any votes for other parties or independents.
  "Closest NoVa County" means the NoVa county closest to DC that contains part of the district;
  a narrow definition of NoVa is used, going only as far as Prince William and Loudoun Counties.
  Incumbents are marked with an asterisk. Click the column headers to sort.
</p>
<div id="container" style="opacity: 0;">
<div id="controls">
  <div class="control-group">
    <div class="form-check form-check-inline">
      <input type="checkbox" id="show-uncontested" class="form-check-input">
      <label class="form-check-label" for="show-uncontested">Show uncontested races</label>
    </div>
  </div>
  <div class="control-group">
    <div class="form-check form-check-inline">
      <input type="checkbox" id="show-all-columns" class="form-check-input">
      <label class="form-check-label" for="show-all-columns">Show all columns</label>
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
          <td<% if (/Margin|\$/.test(key)) { %> <%= marginStyle((key.includes('(R)') ? -1 : 1) * value, (key.includes('$') && dollarMax)) %><% }
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
</div>
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
        return value;numberCol
      }
    };
    const partyCol= {
      width: 20,
      searchable: false,
    };
    const openCol = {
      className: 'text-center',
      width: 20,
      render: function (value, type) {
        return value === 'true' ? '\u2713' : '';
      },
      searchable: false,
    };
    const numberCol = {
      className: 'text-right',
      visible: false,
      render: $.fn.dataTable.render.number(',', '.'),
      searchable: false,
    };
    const marginCol = {
      className: 'text-right',
      width: 30,
      render: function (value, type) {
        if (value === '') {
          return '';
        }
        value = +value;
        return type === 'display' ? (value > 0 ? '+' : value < 0 ? '\u2212' : '') + Math.abs(value) : value;
      },
      searchable: false,
    };
    const nameCol = {
      orderable: false,
    };
    const dollarCol = {
      className: 'text-right',
      visible: false,
      render: function (value, type) {
        if (type !== 'display') {
          return value;
        }
        const abs = Math.abs(value);
        return (value < 0 ? '\u2212' : '') + (abs ? ((abs < 1000 ? '<1' : Math.round(abs / 1000)) + 'k') : '0');
      },
      searchable: false,
    };
    const dollarAdvantageCol = {
      className: 'text-right',
      render: function (value, type) {
        if (type !== 'display') {
          return value;
        }
        let display = dollarCol.render(value, 'display');
        if (value > 0) {
          display = '+' + display;
        }
        return display;
      },
      searchable: false,
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
            .on('draw.dt', () => $('#races-table_wrapper').width($table.width()))
            .one('draw.dt', () => $('#container').css('opacity', 1))
            .on('column-visibility.dt', () => $table.columns.adjust().draw());
    const table = $table.DataTable({
      columns: [
        <% _.forEach(headers, function (header) {
          if (header === 'District') { %>districtCol<% }
          else if (header === 'Party') { %>partyCol<% }
          else if (header === 'Open') { %>openCol<% }
          else if (/\b(?:Votes|D|R)$/.test(header)) { %>numberCol<% }
          else if (/^\$/.test(header)) { %>dollarCol<% }
          else if (/\$ Advantage$/.test(header)) { %>dollarAdvantageCol<% }
          else if (/Margin$/.test(header)) { %>marginCol<% }
          else if (/County$/.test(header)) { %>null<% }
          else { %>nameCol<% } %>,
        <% }); %>
      ],
      fixedHeader: true,
      paging: false
    });
    $('#show-uncontested').on('click', function () { table.draw(); });
    $('#show-chamber input').on('change', function () { table.draw(); });
    const hiddenColumns = [
      <% _.forEach(headers, function (header, i) {
        if (/Raised|\b(?:Votes|D|R)$/.test(header)) { %><%= i %>,<% } %>
      <% }); %>
    ];
    $('#show-all-columns').on('click', function () {
      table.columns(hiddenColumns).visible($(this).prop('checked'));
    });
  });
</script>
<%= '\x3c%= nav %\x3e' %>
</body>
</html>
